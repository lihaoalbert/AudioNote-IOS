//
//  ViewControllerFirst.m
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//
// 功能:
// 1. 语音转文字（科大讯飞）
// 2. 文句解析，找出相对应的分类。（/ProcessPattern)
// 3. 录入文句，解析结果写入数据库。（/DatabaseUtils)
// 3.1 写入数据库同时，post到服务器一份，作为改善算法的参考。

#import <UIKit/UIKit.h>
#import "ViewControllerFirst.h"
#import "ViewControllerSecond.h"
#import "ViewControllerThird.h"

#import "PopupView.h"
#import "processPattern.h"
#import "DatabaseUtils.h"
#import "ViewCommonUtils.h"
#import "ISRDataHelper.h"

//#define myNSLog NSLog
#define myNSLog NSLog

@interface ViewControllerFirst () <IFlySpeechRecognizerDelegate,UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

//识别对象（功能1）
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
//数据上传对象（功能1）
@property (nonatomic, strong) IFlyDataUploader     * uploader;

@property (nonatomic, strong) PopupView            * popUpView;   // show volumn when voice
@property (nonatomic)         BOOL                 isCanceled;    // voice status

// iFly recognizer convert audio to text. （功能1）
@property (nonatomic, nonatomic) NSMutableString    *iFlyRecognizerResult;
@property (nonatomic, nonatomic) NSDate             *iFlyRecognizerStartDate;
@property (nonatomic, nonatomic) NSDateFormatter    *gDateFormatter;
// show iFlyRecognizerResult changing dynamically.
@property (weak, nonatomic) IBOutlet UILabel        *iFlyRecognizerShow;

// latest record list ui
@property (weak, nonatomic) IBOutlet UITableView    *latestView;
@property (nonatomic, nonatomic) NSMutableArray     *latestDataList;
@property (nonatomic, nonatomic) NSInteger          listDataLimit;
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@property (nonatomic, nonatomic) ViewCommonUtils    *viewCommonUtils;

// begin voice record
@property (weak, nonatomic) IBOutlet UIButton       *voiceBtn;

// 调整画面颜色
@property (weak, nonatomic) UIColor                 *gBackground;
@property (weak, nonatomic) UIColor                 *gTextcolor;
@property (weak, nonatomic) UIColor                 *gHighlightedTextColor;
@end


@implementation ViewControllerFirst
@synthesize iFlySpeechRecognizer;
@synthesize iFlyRecognizerResult;
@synthesize iFlyRecognizerStartDate;
@synthesize iFlyRecognizerShow;
@synthesize latestView;
@synthesize latestDataList;
@synthesize gDateFormatter;
@synthesize listDataLimit;
@synthesize gBackground;
@synthesize gTextcolor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup database
    [DatabaseUtils setUP];
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    self.isCanceled      = YES;
    //[self.databaseUtils executeSQL: @"delete from voice_record"];
    
    // config iflyRecognizer
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"5437b538"];
    [IFlySpeechUtility createUtility:initString];
    // 创建识别
    self.iFlySpeechRecognizer = [self.viewCommonUtils CreateRecognizer:self Domain:@"iat"];
    self.uploader = [[IFlyDataUploader alloc] init];
    
    [IFlySetting setLogFile:LVL_NONE]; //未来查看科大讯飞日志时使用: LVL_ALL
    [IFlySetting showLogcat:NO];
    NSLog(@"IFly Version: %@", [IFlySetting getVersion]);
    
    
    // recognizer result
    self.iFlyRecognizerResult = [[NSMutableString alloc] init];
    // global date foramt
    self.gDateFormatter = [[NSDateFormatter alloc] init];
    [self.gDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    // latest n rows data list view
    self.listDataLimit = 5;
    self.latestView.delegate   = self;
    self.latestView.dataSource = self;
    
    //self.latestView = [self.latestView initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    self.latestView.backgroundColor = [UIColor clearColor];
    self.latestView.opaque = NO;
    self.parentViewController.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.5 alpha:0.7];
    //[self.latestView setEditing:YES animated:YES];
    self.latestDataList = [self.viewCommonUtils getDataListWith: self.databaseUtils Limit: self.listDataLimit Offset: 0];

    // 开始录音按钮设置与启动
    [self.voiceBtn addTarget:self action:@selector(startVoiceRecord) forControlEvents:UIControlEventTouchDown];
    [self.voiceBtn addTarget:self action:@selector(stopVoiceRecord) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 录音中的画面显示
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/2, self.view.frame.size.width/2, self.view.frame.size.height/2)];
    self.popUpView.ParentView = self.view;
    [self.popUpView setText: @"音量:0"];
    //[self.view addSubview:self.popUpView];
    
    self.gBackground = [UIColor blackColor];
    self.gTextcolor  = [UIColor whiteColor];
    self.gHighlightedTextColor  = [UIColor orangeColor];
    
    
    NSLog(@"TableView: %f", self.latestView.bounds.size.width);
    NSLog(@"view:%f", self.view.bounds.size.width);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
 NSLog(@"View Did applicationDidBecomeActive");
}

- (void)viewVillAppear:(BOOL)animated {
    NSLog(@"View Did viewVillAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"View Did Disappear");
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
    self.gBackground    = nil;
    self.gTextcolor     = nil;
    self.gHighlightedTextColor     = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self.popUpView setText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
    }
    
    [self.popUpView setText: @"请说话"];
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
    //NSLog(@"isCanceled: %i, Volumne:%@", self.isCanceled, vol);
    //NSLog(@"iFlyRecognizerResult: %@", self.iFlyRecognizerResult.copy);
    [self.popUpView setText:vol];
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
    NSLog(@"onError: %@",error);
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    // result数组内容很复杂，提取最简单的语音转义字符串
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    NSDictionary    *dic = results[0];
    for (NSString *key in dic) {
        [mutableString appendFormat:@"%@",key];
    }
    NSString *resultStr = [[ISRDataHelper shareInstance] getResultFromJson:mutableString];
    //NSLog(@"听写结果：%@",resultStr);
    
    [self.iFlyRecognizerResult appendFormat:@"%@",resultStr];

    
    // 录音过程中，实时显示录音转义文句，暂时未使用到
    //self.iFlyRecognizerShow.text = self.iFlyRecognizerResult;
    
    // monitor whether recognize continue
    // operation only when finished converting
    if (isLast == YES) {
        if([self.iFlyRecognizerResult length] == 0) {
            [self.popUpView setText:@"未创建"];
            [self.view addSubview:self.popUpView];
        } else {
            // caculate duration
            NSTimeInterval duration = [self.iFlyRecognizerStartDate timeIntervalSinceNow];
            NSInteger t_duration    = round(duration < 0 ? -duration : duration);
            NSString *t_createTime  = [self.gDateFormatter stringFromDate:self.iFlyRecognizerStartDate];
            
            NSLog(@"**************************");
            NSLog(@"content:  %@", self.iFlyRecognizerResult);
            NSLog(@"created:  %@", t_createTime);
            NSLog(@"duration: %li", t_duration);
            NSLog(@"**************************");
            
            
            ////////////////////////////////
            // Process input
            // All the result will be saved in g_szRemain, g_szType,g_nMoney,g_nTime
            ////////////////////////////////
            
            // 下面开始实现功能2
            // default value then not deal with failed
            NSString *t_nTime    = @"0";
            NSString *t_nMoney   = @"0";
            NSString *t_szType   = @"";
            NSString *t_szRemain = @"";
            
            char szTemp[MAX_INPUT_LEN];
            strcpy(szTemp,(char *)[self.iFlyRecognizerResult.copy UTF8String]);
            szTemp[MAX_INPUT_LEN-1] = '\0';
            if (process(szTemp, self.databaseUtils) == SUCCESS) {
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
            if(lastRowId > 0)
                NSLog(@"Insert Into Database#%li - successfully.", lastRowId);
            else
                NSLog(@"Insert Into Database#%li - failed.", lastRowId);
            
            ////////////////////////////////
            // 3.1 写入数据库同时，post到服务器一份，作为改善算法的参考。
            ////////////////////////////////
            NSString *device  = [NSString stringWithFormat:@"device=name:%@", [[UIDevice currentDevice] name]];
            device = [device stringByAppendingFormat:@",model:%@", [[UIDevice currentDevice] model]];
            device = [device stringByAppendingFormat:@",localizedModel:%@", [[UIDevice currentDevice] localizedModel]];
            device = [device stringByAppendingFormat:@",systemName:%@", [[UIDevice currentDevice] systemName]];
            device = [device stringByAppendingFormat:@",identifierForVendor:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            device = [device stringByAppendingFormat:@",IFlyVersion:%@", [IFlySetting getVersion]];
            NSString *data = [NSString stringWithFormat:@"data={\"input\":\"%@\"", self.iFlyRecognizerResult.copy];
            data = [data stringByAppendingFormat:@", \"szRemain\":\"%@\"", t_szRemain];
            data = [data stringByAppendingFormat:@", \"szType\":\"%@\"", t_szType];
            data = [data stringByAppendingFormat:@", \"nMoney\":\"%@\"", t_nMoney];
            data = [data stringByAppendingFormat:@", \"nTime\":\"%@\"", t_nTime];
            data = [data stringByAppendingString:@"}"];

            NSString *path = [NSString stringWithFormat:@"%@&%@", device, data];
            NSString *response = [self.viewCommonUtils httpPost: path];
            NSLog(@"Response: %@", response);
            // 功能 3.1 END
            
            
            self.latestDataList = [self.viewCommonUtils getDataListWith: self.databaseUtils Limit: self.listDataLimit Offset: 0];
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
    return [self.latestDataList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.backgroundColor                 = self.gBackground;
    cell.textLabel.backgroundColor       = self.gBackground;
    cell.detailTextLabel.backgroundColor = self.gBackground;
    cell.textLabel.textColor       = self.gTextcolor;
    cell.detailTextLabel.textColor = self.gTextcolor;
    
    cell.textLabel.highlightedTextColor  = self.gHighlightedTextColor;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = self.gBackground;
    
    
    NSMutableDictionary *dict = [self.latestDataList objectAtIndex:indexPath.row];
    cell.textLabel.text       = dict[@"detail"];
    cell.detailTextLabel.text = dict[@"category"];
    return cell;
}

#pragma mark - <CurrentShow>
- (void)didShowCurrent {
    NSLog(@"switch to first view.");
}


@end
