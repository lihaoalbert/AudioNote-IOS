//
//  UpgradeViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/15.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "UpgradeViewController.h"
#import "Version+Pgyer.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "HttpUtils.h"
#import "const.h"

@interface UpgradeViewController ()
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelLatestVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelChangeLog;
@property (strong, nonatomic) IBOutlet UITextView *textViewChangLog;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UIButton *btnUpgrade;
@property (strong, nonatomic) NSString *insertUrl;
@property (strong, nonatomic) Version *version;

@end

@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"版本更新";
    
    _version = [[Version alloc] init];
    [self refreshControls:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"检测中...";

    [hud showAnimated:YES whileExecutingBlock:^{
        [self.version checkUpdate:^{
            [self refreshControls:[self.version isUpgrade]];
        } FailBloc:^{
            if([self.version.errors count] > 0) {
                self.labelChangeLog.text = @"fail detail";
                self.labelLatestVersion.text  = [NSString stringWithFormat:@"%@: %@", @"最新版本", @"fail"];
                
                
                NSMutableArray *errors = [NSMutableArray array];
                [errors addObject:[NSString stringWithFormat:@"url:\n%@\n", PGYER_INFO_URL]];
                [errors addObject:@"error:"];
                [errors addObject:[self.version.errors[0] localizedDescription]];
                
                self.textViewChangLog.text    = [errors componentsJoinedByString:@"\n"];
            }
        }];
    } completionBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - controls action
- (IBAction)actionUpgrade:(id)sender {
    NSString *pgyer = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https%%3A%%2F%%2Fwww.pgyer.com%%2Fapiv1%%2Fapp%%2Fplist%%3FaId%%3D%@%%26_api_key%%3D%@", PGYER_APP_ID, PGYER_APP_KEY];
    NSLog(@"%@", pgyer);
    NSURL *url = [NSURL URLWithString:pgyer];
    NSLog(@"url: %@", url);
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionOpenURL:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:PYGER_PUBLIC_URL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - private methods

- (void)refreshControls:(BOOL)btnEnabled {
    //self.labelTitle.text = ([self.version isUpgrade] ? t(@"UPGRADE_PROMPT_NEW") : t(@"UPGRADE_PROMPT_NONE"));
    self.labelCurrentVersion.text = [NSString stringWithFormat:@"%@: %@", @"当前版本", self.version.current];
    self.labelLatestVersion.text  = [NSString stringWithFormat:@"%@: %@", @"最新版本", self.version.latest];
    self.textViewChangLog.text    = self.version.changeLog;
    self.insertUrl                = self.version.insertURL;
    [self enabledBtn:self.btnSkip Enabeld:btnEnabled];
    [self enabledBtn:self.btnUpgrade Enabeld:btnEnabled];
}

- (void)enabledBtn:(UIButton *)sender Enabeld:(BOOL)enabled {
    if(enabled == sender.enabled) {
        return;
    }
    
    sender.enabled = enabled;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:sender.titleLabel.text];
    NSRange strRange = {0,[str length]};
    if(enabled) {
        [str removeAttribute:NSStrikethroughStyleAttributeName range:strRange];
        
    }
    else {
        [str addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    }
    [sender setAttributedTitle:str forState:UIControlStateNormal];
}

@end
