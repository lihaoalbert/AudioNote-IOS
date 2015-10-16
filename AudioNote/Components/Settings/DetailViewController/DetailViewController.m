//
//  DetailViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/15.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "DetailViewController.h"
#import "Version.h"
#import "FileUtils.h"
#import "const.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listView;

@property (strong, nonatomic) NSArray *dataList;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dataList = [NSArray array];
    NSString *title = @"notset";
    
    switch(_indexPath) {
        case SettingsAppInfo: {
            Version *version = [[Version alloc] init];
            _dataList = @[
                          @[@"应用信息",
                            @[
                              @[@"应用名称", version.appName],
                              @[@"当前版本", version.current],
                              ]
                            ],
                          @[@"设备信息",
                            @[
                              @[@"系统语言", version.lang],
                              @[@"设备名称", [Version machineHuman]],
                              @[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize]],
                              @[@"可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize]]
                              ]
                            ]
                          ];
            title = @"应用信息";
            break;
        }
        default:
            break;
    }
    
    self.navigationItem.title = title;
    
    
    self.listView.backgroundColor = [UIColor whiteColor];
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentLeft];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor grayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataList count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return _dataList[section][0];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList[section][1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *infos = _dataList[section][1][row];
    
    cell.textLabel.text = infos[0];
    cell.detailTextLabel.text = infos[1];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [UIColor whiteColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}
@end
