//
//  ExportViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/18.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "ExportViewController.h"
#import "DatabaseUtils.h"

@interface ExportViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelNum;
@property (weak, nonatomic) IBOutlet UILabel *labelBegin;
@property (weak, nonatomic) IBOutlet UILabel *labelEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelSize;
@property (weak, nonatomic) IBOutlet UIButton *btnExport;

@end

@implementation ExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DatabaseUtils *dbUtils = [[DatabaseUtils alloc] init];
    NSMutableArray *dataList = [dbUtils exportReport];
    
    _labelNum.text = [NSString stringWithFormat:@"笔数: %@", dataList[0]];
    _labelBegin.text = [NSString stringWithFormat:@"开始时间: %@", dataList[1]];
    _labelEnd.text = [NSString stringWithFormat:@"截止时间: %@", dataList[2]];
    _labelSize.text = [NSString stringWithFormat:@"数据大小: %@", [dbUtils dbSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
