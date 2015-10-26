//
//  ExportViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/18.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "NormalSettingsController.h"
#import "const.h"
#import "DatabaseUtils.h"
#import <MessageUI/MessageUI.h>
#import "ViewUtils.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "DataHelper.h"
#import <SSZipArchive.h>
#import <MBProgressHUD.h>
#import "GesturePasswordController.h"

@interface NormalSettingsController () <MFMailComposeViewControllerDelegate, GesturePasswordControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelNum;
@property (weak, nonatomic) IBOutlet UILabel *labelBegin;
@property (weak, nonatomic) IBOutlet UILabel *labelEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelSize;
@property (weak, nonatomic) IBOutlet UIButton *btnExport;
@property (weak, nonatomic) IBOutlet UITextField *textfieldWeixinUID;
@property (weak, nonatomic) IBOutlet UIButton *btnBindWeixin;
@property (weak, nonatomic) IBOutlet UIImageView *imageviewWeixinHead;
@property (weak, nonatomic) IBOutlet UILabel *labelWeixinNick;
@property (weak, nonatomic) IBOutlet UILabel *labelWeixinSex;
@property (weak, nonatomic) IBOutlet UILabel *labelWeixinArea;
@property (weak, nonatomic) IBOutlet UILabel *labelStateWeixin;
@property (weak, nonatomic) IBOutlet UISwitch *switchPushToServer;
@property (weak, nonatomic) IBOutlet UILabel *labelPushToServerInfo;
@property (weak, nonatomic) IBOutlet UISwitch *switchGesturePassword;
@property (weak, nonatomic) IBOutlet UIView *viewBindWeixin;
@property (weak, nonatomic) IBOutlet UIView *viewWeixinInfo;
@property (weak, nonatomic) IBOutlet UIView *viewPushToServer;
@property (weak, nonatomic) IBOutlet UIView *viewGesturePassword;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) DatabaseUtils *dbUtils;
@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) GesturePasswordController *gesturePasswordController;

@end

@implementation NormalSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_btnExport.layer setCornerRadius:10.0];
    [_imageviewWeixinHead.layer setCornerRadius:10.0];
    _imageviewWeixinHead.layer.borderWidth = 0;
    _imageviewWeixinHead.layer.masksToBounds = YES;
    
    _dbUtils = [[DatabaseUtils alloc] init];
    _dataList = [_dbUtils exportReport];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _labelNum.text   = [NSString stringWithFormat:@"笔数: %@", _dataList[0]];
    _labelBegin.text = [NSString stringWithFormat:@"开始时间: %@", _dataList[1]];
    _labelEnd.text   = [NSString stringWithFormat:@"截止时间: %@", _dataList[2]];
    _labelSize.text  = [NSString stringWithFormat:@"数据大小: %@", [_dbUtils dbSize]];
    _labelPushToServerInfo.text = [NSString stringWithFormat:@"每 %@ 推送本地数据至服务器", [ViewUtils humanTimeInterval:PUSH_DATA_TO_SERVER_INTERVAL]];
    
    [self setWeixinerInfo];
}
- (IBAction)actionExport:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
        [self sendEmailAction]; // 调用发送邮件的代码
    }
    else {
        [ViewUtils showPopupView:self.view Info:@"未设置邮件帐户"];
    }
}

- (IBAction)actionBindWeixin:(UIButton *)sender {
    NSString *weixinerUID = _textfieldWeixinUID.text;
    if(weixinerUID && [weixinerUID length] > 0) {
        [self showProgressHUD:@"获取微信信息..."];
        
        NSMutableDictionary *weixinerInfo = [DataHelper getWeixinInfo:weixinerUID];
        if(weixinerInfo && [weixinerInfo[@"code"] isEqualToNumber:@1]) {
            _progressHUD.labelText = @"缓存微信头像...";
            [self cacheWeixinerAvatar:weixinerInfo];
            
            _progressHUD.labelText = @"绑定设备...";
            [DataHelper postDevice];
            _progressHUD.labelText = @"绑定微信...";
            [DataHelper bindWeixin:weixinerUID];
            
            [self setWeixinerInfo];
        }
        else {
            [_progressHUD hide:YES];
            [ViewUtils showPopupView:self.view Info:[NSString stringWithFormat:@"未找到微信账号(%@)", weixinerUID]];
        }
        [_progressHUD hide:YES];
    }
    else {
        [ViewUtils showPopupView:self.view Info:@"请输入微信账号UID."];
    }
}
- (void)cacheWeixinerAvatar:(NSMutableDictionary *)weixinerInfo {
    NSURL *url = [[NSURL alloc] initWithString:weixinerInfo[@"weixiner_info"][@"headimgurl"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *imageName = [NSString stringWithFormat:@"%@.png", weixinerInfo[@"weixiner_info"][@"openid"]];
    NSString *imagePath = [FileUtils dirPath:CACHE_DIRNAME FileName:imageName];
    if(data){
        [[NSFileManager defaultManager] createFileAtPath:imagePath contents:data attributes:nil];
    }
    
}
- (void)setWeixinerInfo {
    NSString *weixinerInfoConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:WEIXINER_CONFIG_FILENAME];
    NSDictionary *weixinerInfo = [FileUtils readConfigFile:weixinerInfoConfigPath];
    
    if(weixinerInfo && [weixinerInfo[@"code"] isEqualToNumber:@1]) {
        _labelWeixinNick.text = weixinerInfo[@"weixiner_info"][@"nickname"];
        _labelWeixinSex.text = weixinerInfo[@"weixiner_info"][@"sex"];
        _labelWeixinArea.text = weixinerInfo[@"weixiner_info"][@"area"];
        
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", weixinerInfo[@"weixiner_info"][@"openid"]];
        NSString *imagePath = [FileUtils dirPath:CACHE_DIRNAME FileName:imageName];
        _imageviewWeixinHead.image = [UIImage imageWithContentsOfFile:imagePath];
        
        NSString *weixinBindDeviceConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:WEIXIN_BIND_DEVICE_FILENAME];
        NSDictionary *weixinBindDeviceInfo = [FileUtils readConfigFile:weixinBindDeviceConfigPath];
        _labelStateWeixin.text = [NSString stringWithFormat:@"绑定 %@", ([weixinBindDeviceInfo[@"code"] isEqualToNumber:@1] ? @"成功" : @"失败")];
        
        
        NSString *settingsConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:SETTINGS_CONFIG_FILENAME];
        NSDictionary *settingsInfo = [FileUtils readConfigFile:settingsConfigPath];
        _switchPushToServer.on = (settingsInfo && [settingsInfo[@"auto_push_data_to_server"] isEqualToNumber:@1]);
        _switchGesturePassword.on = (settingsInfo && [settingsInfo[@"use_gesture_password"] isEqualToNumber:@1]);
        
        _viewWeixinInfo.hidden = NO;
        _viewBindWeixin.hidden = YES;
        _viewPushToServer.hidden = NO;
        _viewGesturePassword.hidden = NO;
    }
    else {
        _viewWeixinInfo.hidden = YES;
        _viewBindWeixin.hidden = NO;
        _viewPushToServer.hidden = YES;
        _viewGesturePassword.hidden = YES;
    }
}

- (void)sendEmailAction {
    
    [self showProgressHUD:@"生成数据..."];
        
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:@"yyyyMMddHHmmss"];
    NSMutableArray *array = [NSMutableArray array];
    array = [_dbUtils selectLimit:100000000 Offset:0 Order:@"id" Format:@"json"];
    NSString *fileName = [NSString stringWithFormat:@"export-%@", currentDate];
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    json[@"data"] = array;
    NSString *jsonPath = [FileUtils dirPath:CACHE_DIRNAME FileName:[NSString stringWithFormat:@"%@.json", fileName]];
    [FileUtils writeJSON:json Into:jsonPath];
    
    NSString *zippedPath = [FileUtils dirPath:CACHE_DIRNAME FileName:[NSString stringWithFormat:@"%@.zip", fileName]];
    NSArray *inputPaths = [NSArray arrayWithObjects: jsonPath, nil];
    [SSZipArchive createZipFileAtPath:zippedPath withFilesAtPaths:inputPaths];
    
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:[NSString stringWithFormat:@"数据导出-%@", currentDate]];
    // 设置收件人
    //    [mailCompose setToRecipients:@[@"1147626297@qq.com"]];
    //    // 设置抄送人
    //    [mailCompose setCcRecipients:@[@"1229436624@qq.com"]];
    //    // 设置密抄送
    //    [mailCompose setBccRecipients:@[@"shana_happy@126.com"]];
    /**
     *  添加附件
     */
    
    NSData *zippedData = [NSData dataWithContentsOfFile:zippedPath];
    [mailCompose addAttachmentData:zippedData mimeType:@"application/zip" fileName:[NSString stringWithFormat:@"%@.zip", fileName]];
    /**
     *  设置邮件的正文内容
     */
    NSString *fileHumainSize = [FileUtils humanFileSize:[FileUtils fileSize:zippedPath]];
    NSString *emailContent = [NSString stringWithFormat:@"笔数: %@\n开始时间: %@\n截止时间: %@\n附件大小: %@\n", _dataList[0], _dataList[1], _dataList[2], fileHumainSize];
    
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    //	[mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    
    //    UIImage *image = [UIImage imageNamed:@"macphone"];
    //    NSData *imageData = UIImagePNGRepresentation(image);
    //    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"macphone.png"];
    
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:^{
        [_progressHUD hide:YES];
    }];


}
- (IBAction)TextField_DidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionWhetherPushDataToServer:(UISwitch *)sender {
    NSString *settingsConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:SETTINGS_CONFIG_FILENAME];
    NSDictionary *settingsInfo = [FileUtils readConfigFile:settingsConfigPath];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:settingsInfo];
    
    dict[@"auto_push_data_to_server"] = (sender.isOn ? @1 : @0);
    
    [FileUtils writeJSON:dict Into:settingsConfigPath];
}

- (IBAction)actionWehtherUseGesturePassword:(UISwitch *)sender {
    if([sender isOn]) {
        _gesturePasswordController = [[GesturePasswordController alloc] init];
        _gesturePasswordController.delegate = self;
        [self presentViewController:_gesturePasswordController animated:YES completion:nil];
    }
    else {
        NSString *settingsConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:SETTINGS_CONFIG_FILENAME];
        NSDictionary *settingsInfo = [FileUtils readConfigFile:settingsConfigPath];
        NSMutableDictionary *settingsInfoEditor = [NSMutableDictionary dictionaryWithDictionary:settingsInfo];
        settingsInfoEditor[@"use_gesture_password"] = @0;
        [FileUtils writeJSON:settingsInfoEditor Into:settingsConfigPath];
        
        [ViewUtils showPopupView:self.view Info:@"禁用手势锁设置成功"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _gesturePasswordController.delegate = nil;
    _gesturePasswordController = nil;
}

- (void)showProgressHUD:(NSString *)msg {
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.labelText = msg;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
}


#pragma mark - GesturePasswordControllerDelegate
- (void)verifySucess {
    NSString *settingsConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:SETTINGS_CONFIG_FILENAME];
    NSDictionary *settingsInfo = [FileUtils readConfigFile:settingsConfigPath];
    if(![settingsInfo[@"use_gesture_password"] isEqualToNumber:@1]) {
        NSMutableDictionary *settingsInfoEditor = [NSMutableDictionary dictionaryWithDictionary:settingsInfo];
        settingsInfoEditor[@"use_gesture_password"] = @1;
        [FileUtils writeJSON:settingsInfoEditor Into:settingsConfigPath];
    }
    
    [_gesturePasswordController dismissViewControllerAnimated:YES completion:nil];
    _gesturePasswordController.delegate = nil;
    _gesturePasswordController = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
