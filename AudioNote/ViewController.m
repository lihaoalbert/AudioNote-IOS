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

// iFly recognizer ui.
@property (nonatomic, nonatomic) IFlyRecognizerView *iFlyRecognizerView;
// iFly recognizer convert audio to text.
@property (nonatomic, nonatomic) NSMutableString *iFlyRecognizerResult;
// show iFlyRecognizerResult changing dynamically.
@property (weak, nonatomic) IBOutlet UILabel *iFlyRecognizerShow;

// latest record list ui
@property (weak, nonatomic) IBOutlet UITableView *latestView;
@property (nonatomic, nonatomic) NSMutableArray *latestDataList;

@end


@implementation ViewController

@synthesize iFlyRecognizerView;
@synthesize iFlyRecognizerResult;
@synthesize iFlyRecognizerShow;
@synthesize latestView;
@synthesize latestDataList;

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

    // latest 3 rows data list view
    self.latestView.delegate = self;
    self.latestView.dataSource = self;
    [self.latestView setEditing:YES animated:YES];
    self.latestDataList = [[NSMutableArray alloc] initWithObjects:@"first",@"two",@"three",nil];
    
    // init recognizer result
    self.iFlyRecognizerResult = [[NSMutableString alloc] init];

}

- (void)viewDidUnload {
    self.iFlyRecognizerView = nil;
    self.iFlyRecognizerResult = nil;
    self.iFlyRecognizerShow = nil;
    self.latestView = nil;
    self.latestDataList = nil;
    [self setIFlyRecognizerView:nil];
    [self setIFlyRecognizerResult:nil];
    [self setIFlyRecognizerShow:nil];
    [self setLatestView:nil];
    [self setLatestDataList:nil];
    
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
            
            // add convert words to TableView
            [self.latestDataList addObject: self.iFlyRecognizerResult.copy];
            [self.latestView reloadData];;
        }
        
        // set recognizer result empty
        [self.iFlyRecognizerResult setString:@""];
        NSLog(@"convert finished!");
    } else {
        NSLog(@"convert...");
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
