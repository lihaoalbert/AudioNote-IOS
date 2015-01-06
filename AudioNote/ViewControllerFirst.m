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
#import "DatabaseUtils.h"
#import "ViewCommonUtils.h"

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
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@property (nonatomic, nonatomic) ViewCommonUtils    *viewCommonUtils;


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
    
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    
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
    self.latestView.delegate   = self;
    self.latestView.dataSource = self;
    [self.latestView setEditing:YES animated:YES];
    self.latestDataList = [self.viewCommonUtils getDataListWithDB: self.databaseUtils];
    
    
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
    self.databaseUtils  = nil;
    [self setIFlyRecognizerView:nil];
    [self setIFlyRecognizerResult:nil];
    [self setIFlyRecognizerShow:nil];
    [self setLatestView:nil];
    [self setLatestDataList:nil];
    [self setGDateFormatter:nil];
    [self setDatabaseUtils:nil];
    
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
// params
// (NSArray *)resultArray - voice convert to words result
// isLast:(BOOL) isLast   - when YES then convert over
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    // 1.a append recognize text into iFlyRecognizerResult
    for (NSString *key in dic) {
        if([key length] > 0) // skip empty string
            [self.iFlyRecognizerResult appendFormat:@"%@",key];
    }
    
    // 1.b show recognize text changing dynamically.
    self.iFlyRecognizerShow.text = self.iFlyRecognizerResult;
    
    // monitor whether recognize continue
    // 2.b operation only when finished convert
    if (isLast == YES) {
        if([self.iFlyRecognizerResult length] > 0) {
            // reload latest 3 rows data
            if([self.latestDataList count] >= 3)
                [self.latestDataList removeObjectAtIndex:0];
            
            // caculate duration
            NSTimeInterval duration = [self.iFlyRecognizerStartDate timeIntervalSinceNow];
            NSInteger t_duration    = round(duration < 0 ? -duration : duration);
            NSString *t_createTime  = [self.gDateFormatter stringFromDate:self.iFlyRecognizerStartDate];
            /*
            const char *szInput =[self.iFlyRecognizerResult UTF8String];
            const char *szBegin =[startDateStr UTF8String];
            int szDuration = (int)duration_int;
             */
            
            NSLog(@"**************************");
            NSLog(@"content:  %@", self.iFlyRecognizerResult);
            NSLog(@"created:  %@", t_createTime);
            NSLog(@"duration: %li", t_duration);
            NSLog(@"**************************");
            
            
            ////////////////////////////////
            // Process input
            // All the result will be saved in g_szRemain, g_szType,g_nMoney,g_nTime
            ////////////////////////////////
            
            // default value then not deal with failed
            NSString *t_nTime    = @"0";
            NSString *t_nMoney   = @"0";
            NSString *t_szType   = @"";
            NSString *t_szRemain = @"";
            
            char szTemp[MAX_INPUT_LEN];
            strcpy(szTemp,(char *)[self.iFlyRecognizerResult.copy UTF8String]);
            szTemp[MAX_INPUT_LEN-1] = '\0';
            if (process(szTemp) == SUCCESS) {
                ////////////////////////////////
                // Insert to DB (process successfully)
                ////////////////////////////////
                t_nTime    = [NSString stringWithFormat:@"%d", g_nTime];
                t_nMoney   = [NSString stringWithFormat:@"%d", g_nMoney];
                t_szType   = [NSString stringWithUTF8String: g_szType];
                t_szRemain = [NSString stringWithUTF8String: g_szRemain];

            }
            NSString *insertSQL = [NSString stringWithFormat: @"Insert into voice_record(input,description,category,nMoney,nTime,begin,duration,create_time,modify_time) VALUES('%@','%@','%@',%@,%@,'%@',%li,'%@','%@');", self.iFlyRecognizerResult.copy, t_szRemain, t_szType, t_nMoney, t_nTime, t_createTime, t_duration,  t_createTime, t_createTime];
            
            NSLog(@"Insert SQL:\n%@", insertSQL);

            
            NSInteger lastRowId = [self.databaseUtils insertDBWithSQL: insertSQL];
            NSLog(@"Insert Into SQL#%li - successfully.", lastRowId);


            
            
            self.latestDataList = [self.viewCommonUtils getDataListWithDB: self.databaseUtils];
            [self.latestView reloadData];
        }
        
        // set recognizer result empty
        [self.iFlyRecognizerResult setString:@""];
        NSLog(@"convert finished!");
    }
    // 2.a do nothing when continue
    else {
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
