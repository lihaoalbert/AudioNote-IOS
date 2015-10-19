//
//  SettingsViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/15.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "SettingsViewController.h"
#import "Version.h"
#import "FileUtils.h"
#import "const.h"
#import "DetailViewController.h"
#import "UpgradeViewController.h"
#import "ExportViewController.h"

@interface SettingsViewController() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *listView;

@property (strong, nonatomic) NSArray *dataList;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *barItemBack = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(actionNavBack:)];
    self.navigationItem.rightBarButtonItem = barItemBack;
    self.navigationItem.title = @"设置";
    
    
    long long fileSize = [[FileUtils appDocutmentSize] longLongValue];
    NSString *fileSize2 = [NSString stringWithFormat:@"%lli", fileSize];
    
    _dataList = @[
                  @[@"应用信息", [[Version alloc] init].current],
                  @[@"本地文件", [FileUtils humanFileSize:fileSize2]],
                  @[@"数据导出", @""],
                  @[@"版本更新", @""]
                  ];
    
    
    self.listView.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    
    NSArray *infos = _dataList[indexPath.row];
    cell.textLabel.text       = infos[0];
    cell.detailTextLabel.text = infos[1];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row != SettingsFileInfo) {
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SettingsAppInfo: {
            
            DetailViewController *detailVC = [[DetailViewController alloc] init];
            detailVC.indexPath = indexPath.row;
            [self.navigationController pushViewController:detailVC animated:YES];
            
            break;
        }
        case SettingsExport: {
         
            ExportViewController *exportVC = [[ExportViewController alloc] init];
            [self.navigationController pushViewController:exportVC animated:YES];
            
            break;
        }
        case SettingsUpgrade: {
            
            UpgradeViewController *upgradeVC = [[UpgradeViewController alloc] init];
            [self.navigationController pushViewController:upgradeVC animated:YES];
            
            break;
        }
        default:
            break;
    }
}

- (void)actionNavBack:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
