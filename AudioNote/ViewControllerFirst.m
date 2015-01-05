//
//  ViewControllerFirst.m
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import "ViewControllerFirst.h"
#import "ViewControllerSecond.h"
#import "ViewControllerThird.h"
#import "Phantom.h"
#import "Database_Utils.h"

// comment by hand
// code will run normally without them.
@interface ViewControllerFirst () <IFlyRecognizerViewDelegate, UITableViewDelegate, UITableViewDataSource>

// iFly recognizer ui.
@property (nonatomic, nonatomic) IFlyRecognizerView *iFlyRecognizerView;
// iFly recognizer convert audio to text.
@property (nonatomic, nonatomic) NSMutableString    *iFlyRecognizerResult;
@property (nonatomic, nonatomic) NSDate             *iFlyRecognizerStartDate;
@property (nonatomic, nonatomic) NSDateFormatter    *gDateFormatter;
// show iFlyRecognizerResult changing dynamically.
@property (weak, nonatomic) IBOutlet UILabel        *iFlyRecognizerShow;
// latest record list ui
@property (weak, nonatomic) IBOutlet UITableView    *latestView;
@property (nonatomic, nonatomic) NSMutableArray     *latestDataList;


@end


@implementation ViewControllerFirst

@synthesize iFlyRecognizerView;
@synthesize iFlyRecognizerResult;
@synthesize iFlyRecognizerStartDate;
@synthesize iFlyRecognizerShow;
@synthesize latestView;
@synthesize latestDataList;
@synthesize gDateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // config iflyRecognizerView
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"5437b538"];
    [IFlySpeechUtility createUtility:initString];
    self.iFlyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center]; // self.view.center
    self.iFlyRecognizerView.delegate = self;
    [self.iFlyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //ASR_AUDIO_PATH: save record file name, set nil if not need, default file direcotry: /documents
    [self.iFlyRecognizerView setParameter:@"asrview.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    // result not include punctuate
    [self.iFlyRecognizerView setParameter:@"0" forKey:@"asr_ptt"];
    // result_type: json，xml，plain，default: json。
    [self.iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    // Language
    //[iflySpeechRecognizer setParameter:@"language" value:@"en_us"];
    // logger
    [IFlySetting setLogFile:LVL_NONE]; //LVL_ALL
    [IFlySetting showLogcat:NO];
    
    
    NSLog(@"IFly Version: %@", [IFlySetting getVersion]);
    
    
    // init recognizer result
    self.iFlyRecognizerResult = [[NSMutableString alloc] init];
    
    // global date foramt
    self.gDateFormatter = [[NSDateFormatter alloc] init];
    [self.gDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    // latest 3 rows data list view
    self.latestView.delegate = self;
    self.latestView.dataSource = self;
    [self.latestView setEditing:YES animated:YES];
    // this block code will be recall every voice record.
    // feel good when put into function
    self.latestDataList = initDataListWithDB();
    
    
    // UIBar
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(selectLeftAction:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(selectRightAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Gesture
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSecondView)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToThirdView)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gestureLeft];
}

// Swipe Gesture Functions
-(void)swipeToSecondView
{
    ViewControllerSecond *secondView = [[ViewControllerSecond alloc] init];
    [self.navigationController pushViewController:secondView animated:YES];
    secondView.title = @"明细列表";
}

-(void)swipeToThirdView
{
    ViewControllerThird *thirdView = [[ViewControllerThird alloc] init];
    [self.navigationController pushViewController:thirdView animated:YES];
    thirdView.title = @"数据报表";
}

- (void)viewDidUnload {
    self.iFlyRecognizerView = nil;
    self.iFlyRecognizerResult = nil;
    self.iFlyRecognizerShow = nil;
    self.latestView = nil;
    self.latestDataList = nil;
    self.gDateFormatter = nil;
    [self setIFlyRecognizerView:nil];
    [self setIFlyRecognizerResult:nil];
    [self setIFlyRecognizerShow:nil];
    [self setLatestView:nil];
    [self setLatestDataList:nil];
    [self setGDateFormatter:nil];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)startUpVoice:(id)sender {
    [self.iFlyRecognizerView start];
    
    // clear text when start recognizer tart
    self.iFlyRecognizerShow.text = @"";
    self.iFlyRecognizerStartDate = [NSDate date];
}

#pragma mark - UIBarButtonItem#Action

-(void)selectLeftAction:(id)sender
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你点击了导航栏左按钮" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

-(void)selectRightAction:(id)sender
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你点击了导航栏右按钮" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

#pragma mark - <IFlyRecognizerViewDelegate>

// iflyRecognizer callback functions begin

// 识别结果返回代理
// params
// (NSArray *)resultArray - voice convert to words result
// isLast:(BOOL) isLast   - when YES then convert over
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        if([key length] > 0) // skip empty string
            [self.iFlyRecognizerResult appendFormat:@"%@",key];
    }
    // show recognizer result changing dynamically.
    self.iFlyRecognizerShow.text = self.iFlyRecognizerResult;
    
    // operation only when finished convert
    if (isLast == YES) {
        if([self.iFlyRecognizerResult length] > 0) {
            // reload latest 3 rows data
            if([self.latestDataList count] >= 3)
                [self.latestDataList removeObjectAtIndex:0];
            
            // caculate duration
            NSTimeInterval duration = [self.iFlyRecognizerStartDate timeIntervalSinceNow];
            NSInteger duration_int  = round(duration < 0 ? -duration : duration);
            NSString *startDateStr  = [self.gDateFormatter stringFromDate:self.iFlyRecognizerStartDate];
            NSLog(@"**************************");
            NSLog(@"content:  %@", self.iFlyRecognizerResult);
            NSLog(@"created:  %@", startDateStr);
            NSLog(@"duration: %li", duration_int);
            NSLog(@"**************************");
            
            
            int myid;
            const char *szInput =[self.iFlyRecognizerResult UTF8String];
            const char *szBegin =[startDateStr UTF8String];
            int szDuration = (int)duration_int;
            myid = insertDB(szInput, szBegin, szDuration);
            printf("After Create, ID=%d\n",myid);
            
            
            self.latestDataList = initDataListWithDB();
            // add convert words to TableView
            //[self.latestDataList addObject: self.iFlyRecognizerResult.copy];
            
            [self.latestView reloadData];;
        }
        
        // set recognizer result empty
        [self.iFlyRecognizerResult setString:@""];
        NSLog(@"convert finished!");
    } else {
        NSLog(@"convert...");
    }
    
}


// iflyRecognizer Error Callback
- (void)onError: (IFlySpeechError *) error {
    NSLog(@"%d", [error errorCode]);
    [self.iFlyRecognizerView cancel];
}

// iflyRecognizer callback functions over

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.latestDataList count];// limit num -
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [self.latestDataList objectAtIndex:indexPath.row];
    return cell;
}



@end
