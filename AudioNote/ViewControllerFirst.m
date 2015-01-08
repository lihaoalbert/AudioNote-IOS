//
//  ViewControllerFirst.m
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerFirst.h"
#import "ViewControllerSecond.h"
#import "ViewControllerThird.h"

#import "PopupView.h"
#import "Phantom.h"
#import "DatabaseUtils.h"
#import "ViewCommonUtils.h"
#import "ISRDataHelper.h"

//#define myNSLog NSLog
#define myNSLog NSLog

@interface ViewControllerFirst () <IFlySpeechRecognizerDelegate,UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

//识别对象
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
//数据上传对象
@property (nonatomic, strong) IFlyDataUploader     * uploader;

@property (nonatomic, strong) PopupView            * popUpView;   // show volumn when voice
@property (nonatomic)         BOOL                 isCanceled;    // voice status

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
// begin voice record
@property (weak, nonatomic) IBOutlet UIButton       *voiceBtn;


@end


@implementation ViewControllerFirst
@synthesize iFlySpeechRecognizer;
@synthesize iFlyRecognizerResult;
@synthesize iFlyRecognizerStartDate;
@synthesize iFlyRecognizerShow;
@synthesize latestView;
@synthesize latestDataList;
@synthesize gDateFormatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup database
    [DatabaseUtils setUP];
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    self.isCanceled      = YES;
    [self.databaseUtils executeSQL: @"delete from voice_record"];
    
    
    // config iflyRecognizer
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"5437b538"];
    [IFlySpeechUtility createUtility:initString];
    

    //创建识别
    self.iFlySpeechRecognizer = [self.viewCommonUtils CreateRecognizer:self Domain:@"iat"];
    self.uploader = [[IFlyDataUploader alloc] init];
    
    [IFlySetting setLogFile:LVL_NONE]; //LVL_ALL
    [IFlySetting showLogcat:NO];
    NSLog(@"IFly Version: %@", [IFlySetting getVersion]);
    
    
    // recognizer result
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
    
    
    [self.voiceBtn addTarget:self action:@selector(startVoiceRecord) forControlEvents:UIControlEventTouchDown];
    [self.voiceBtn addTarget:self action:@selector(stopVoiceRecord) forControlEvents:UIControlEventTouchUpInside];
    
    

    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/2, self.view.frame.size.width/2, self.view.frame.size.height/2)];
    self.popUpView.ParentView = self.view;
    [self.popUpView setVolume: @"音量:0" Text: @"请说话"];
    [self.view addSubview:self.popUpView];
}


#pragma mark - Swipe Gesture Functions

-(void)swipeToSecondView {
    ViewControllerSecond *secondView = [[ViewControllerSecond alloc] init];
    //[self.navigationController removeFromParentViewController];

    NSLog(@"%@", self.navigationController.childViewControllers);
    
    [self.navigationController pushViewController:secondView animated:YES];
    secondView.title = @"明细列表";
}

-(void)swipeToThirdView {
    ViewControllerThird *thirdView = [[ViewControllerThird alloc] init];
    //[self.navigationController removeFromParentViewController];
    NSLog(@"%@", self.navigationController.childViewControllers);
    [self.navigationController pushViewController:thirdView animated:YES];
    thirdView.title = @"数据报表";
}



- (void)viewDidUnload {
    //取消识别
    [self.iFlySpeechRecognizer cancel];
    [self.iFlySpeechRecognizer setDelegate: nil];
    self.iFlyRecognizerResult = nil;
    self.iFlyRecognizerShow = nil;
    self.latestView = nil;
    self.latestDataList = nil;
    self.gDateFormatter = nil;
    self.databaseUtils  = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIBarButtonItem#Action

-(void)selectLeftAction:(id)sender {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你点击了导航栏左按钮" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

-(void)selectRightAction:(id)sender {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你点击了导航栏右按钮" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

#pragma mark - Switch Voice Record


-(void)startVoiceRecord {
    self.isCanceled = NO;
    //设置为录音模式
    [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    bool ret = [self.iFlySpeechRecognizer startListening];
    if (ret) {
        // clear text when start recognizer tart
        self.iFlyRecognizerShow.text = @"";
        self.iFlyRecognizerStartDate = [NSDate date];
    } else {
        [self.popUpView setVolume:@"失败" Text: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
    }
    
    [self.popUpView setVolume:@"音量:0" Text: @"请说话"];
    [self.view addSubview:self.popUpView];
    
}

// Stop Voice Record
-(void)stopVoiceRecord {
    [self.iFlySpeechRecognizer stopListening];
    self.isCanceled = YES;
    [self.popUpView removeFromSuperview];
}


#pragma mark - IFlySpeechRecognizerDelegate

/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume {
    if (self.isCanceled) {
        [self.popUpView removeFromSuperview];
        return;
    }
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    NSLog(@"isCanceled: %i, Volumne:%@", self.isCanceled, vol);
    NSLog(@"iFlyRecognizerResult: %@", self.iFlyRecognizerResult.copy);
    [self.popUpView setVolume:vol Text: self.iFlyRecognizerResult.copy];
    [self.view addSubview:self.popUpView];
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech {
    NSLog(@"onBeginOfSpeech");
    
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech {
    NSLog(@"onEndOfSpeech");
}


/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error {
    NSString *text ;
    
    NSLog(@"%@",text);
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    NSDictionary    *dic = results[0];
    
    for (NSString *key in dic) {
        [mutableString appendFormat:@"%@",key];
    }
    
    NSString *resultStr = [[ISRDataHelper shareInstance] getResultFromJson:mutableString];
    NSLog(@"听写结果：%@",resultStr);
    
    [self.iFlyRecognizerResult appendFormat:@"%@",resultStr];

    
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
            
            
            NSInteger lastRowId = [self.databaseUtils executeSQL: insertSQL];
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
