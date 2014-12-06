//
//  ViewController.m
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import "ViewController.h"


// comment by hand
// code will run normally without them.
@interface ViewController () <IFlyRecognizerViewDelegate>

@property (nonatomic, strong) IFlyRecognizerView *iFlyRecognizerView;
@end


@implementation ViewController

@synthesize iFlyRecognizerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // config iflyRecognizerView
    
    // 讯飞语音
    // 创建识别对象
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"5437b538"];
    [IFlySpeechUtility createUtility:initString];
    self.iFlyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center]; // self.view.center
    self.iFlyRecognizerView.delegate = self;
    [self.iFlyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //asr_audio_path保存录音文件名,如不再需要,设置value为nil表示取消,默认目录是documents
    [self.iFlyRecognizerView setParameter:@"asrview.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    // 返回结果不要标点
    [self.iFlyRecognizerView setParameter:@"0" forKey:@"asr_ptt"];
    
    // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [self.iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

}

- (void)viewDidUnload {
    self.iFlyRecognizerView = nil;
    [self setIFlyRecognizerView:nil];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startUpVoice:(id)sender {
    [self.iFlyRecognizerView start];
}

#pragma mark - <IFlyRecognizerViewDelegate>

// iflyRecognizer callback functions begin

// 识别结果返回代理
// params
// (NSArray *)resultArray - voice convert to words result
// isLast:(BOOL) isLast   - when YES then convert over
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    NSLog(@"%@", isLast == YES ? @"over!" : @"convert...");
    NSLog(@"%@", resultArray);
}


// 识别会话错误返回代理
- (void)onError: (IFlySpeechError *) error {
    NSLog(@"%d", [error errorCode]);
    [self.iFlyRecognizerView cancel];
}

// iflyRecognizer callback functions over
@end
