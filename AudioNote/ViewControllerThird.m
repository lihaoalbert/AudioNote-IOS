//
//  ViewControllerThird.m
//  AudioNote
//
//  Created by lijunjie on 15-1-5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
// 数据报表:
// 1. 展示方式: 今日，最近七天，本月，本年，按标签

#import "ViewControllerThird.h"
#import "ViewControllerSecond.h"
#import "ViewControllerFirst.h"
#import "DatabaseUtils.h"

@interface ViewControllerThird () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView      *listView;
@property (nonatomic, nonatomic) NSMutableDictionary  *listDict;
@property (nonatomic, nonatomic) NSArray              *listDictKeys;
@property (nonatomic, nonatomic) DatabaseUtils        *databaseUtils;
@property (weak, nonatomic) UIColor                   *gBackground;
@property (weak, nonatomic) UIColor                   *gTextcolor;
@property (weak, nonatomic) UIColor                   *gHighlightedTextColor;

@end

@implementation ViewControllerThird
@synthesize listDict;
@synthesize listView;
@synthesize databaseUtils;
@synthesize gBackground;
@synthesize gTextcolor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    
    //[self.listView setEditing:YES animated:YES];
    self.databaseUtils = [[DatabaseUtils alloc] init];
    
    NSArray *tagDatas      = (NSArray *)[self.databaseUtils getReportDataWithType: @"Year"];
    NSArray *todayData     = (NSArray *)[self.databaseUtils getReportData: @"today"];
    NSArray *thisWeekData  = (NSArray *)[self.databaseUtils getReportData: @"latest_7_days"];
    NSArray *thisMonthData = (NSArray *)[self.databaseUtils getReportData: @"this_month"];
    NSArray *thisYearData  = (NSArray *)[self.databaseUtils getReportData: @"this_year"];
    
    self.listDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [self.listDict setObject:[NSArray arrayWithArray:todayData]     forKey:@"a. 今日数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisWeekData]  forKey:@"b. 近7天数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisMonthData] forKey:@"c. 本月数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisYearData]  forKey:@"d. 本年数据"];
    [self.listDict setObject:[NSArray arrayWithArray:tagDatas]      forKey:@"e. 分类合计"];
    self.listDictKeys = [[self.listDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    
    self.gBackground            = [UIColor blackColor];
    self.gTextcolor             = [UIColor whiteColor];
    self.gHighlightedTextColor  = [UIColor yellowColor];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listView      = nil;
    self.listDict      = nil;
    self.listDictKeys  = nil;
    self.databaseUtils = nil;
    self.gBackground   = nil;
    self.gTextcolor    = nil;
    self.gHighlightedTextColor = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listDictKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key  = [self.listDictKeys objectAtIndex:section];
    NSArray  *rows = (NSArray *)[self.listDict objectForKey:key];
    
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *key  = [self.listDictKeys objectAtIndex:section];
    NSArray  *rows = (NSArray *)[self.listDict objectForKey:key];
    
    static NSString *GroupedTableIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             GroupedTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:GroupedTableIdentifier];
    }
    cell.backgroundColor                 = self.gBackground;
    cell.textLabel.backgroundColor       = self.gBackground;
    cell.detailTextLabel.backgroundColor = self.gBackground;
    cell.textLabel.textColor             = self.gTextcolor;
    cell.detailTextLabel.textColor       = self.gTextcolor;
    cell.textLabel.highlightedTextColor  = self.gHighlightedTextColor;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = self.gBackground;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [rows objectAtIndex:row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.listDictKeys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}


@end
