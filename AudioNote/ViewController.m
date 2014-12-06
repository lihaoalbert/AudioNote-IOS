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
@interface ViewController () <IFlyRecognizerViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, nonatomic) IFlyRecognizerView *iFlyRecognizerView;
@property (nonatomic, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UITableView *latestView;

@end


@implementation ViewController

@synthesize iFlyRecognizerView;
@synthesize latestView;
@synthesize dataList;

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

    // table view
    //self.latestView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.latestView.delegate = self;
    self.latestView.dataSource = self;
    //self.dataList = [[NSMutableArray alloc] initWithCapacity:3];
    self.dataList = [[NSMutableArray alloc] initWithObjects:@"first",@"two",@"three",nil];

}

- (void)viewDidUnload {
    self.iFlyRecognizerView = nil;
    self.dataList = nil;
    [self setIFlyRecognizerView:nil];
    [self setLatestView:nil];
    
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
    NSLog(@"%@", isLast == YES ? @"convert over!" : @"convert...");

    // add convert words to TableView
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        if([key length] > 0) {
            NSLog(@"%@", key);
            [result appendFormat:@"%@",key];
        }
    }
    
    if([result length] > 0) {
        NSLog(@"%d", [self.dataList count]);
        if([self.dataList count] >= 3) {
            [self.dataList removeObjectAtIndex:0];
        }
        [self.dataList addObject:result];
        [self.latestView reloadData];;
    }
}


// 识别会话错误返回代理
- (void)onError: (IFlySpeechError *) error {
    NSLog(@"%d", [error errorCode]);
    [self.iFlyRecognizerView cancel];
}
// iflyRecognizer callback functions over

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];// limit num -
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [self.dataList objectAtIndex:indexPath.row];
    return cell;
}
@end
