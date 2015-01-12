//
//  ViewControllerThird.m
//  AudioNote
//
//  Created by lijunjie on 15-1-5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewControllerThird.h"
#import "ViewControllerSecond.h"
#import "ViewControllerFirst.h"
#import "DatabaseUtils.h"

@interface ViewControllerThird () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView      *listView;
@property (nonatomic, nonatomic) NSMutableDictionary  *listDict;
@property (nonatomic, nonatomic) NSArray              *listDictKeys;
@property (nonatomic, nonatomic) DatabaseUtils        *databaseUtils;
@end

@implementation ViewControllerThird
@synthesize listDict;
@synthesize listView;
@synthesize databaseUtils;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    
    //[self.listView setEditing:YES animated:YES];
    self.databaseUtils = [[DatabaseUtils alloc] init];
    
    //NSArray *tagDatas      = (NSArray *)[self.databaseUtils reportWithType: @"Year"];
    NSArray *todayData     = (NSArray *)[self.databaseUtils getReportData: @"today"];
    NSArray *thisWeekData  = (NSArray *)[self.databaseUtils getReportData: @"this_week"];
    NSArray *thisMonthData = (NSArray *)[self.databaseUtils getReportData: @"this_month"];
    NSArray *thisYearData  = (NSArray *)[self.databaseUtils getReportData: @"this_year"];
    
    self.listDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [self.listDict setObject:[NSArray arrayWithArray:todayData] forKey:@"a. 今日数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisWeekData] forKey:@"b. 本周数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisMonthData] forKey:@"c. 本月数据"];
    [self.listDict setObject:[NSArray arrayWithArray:thisYearData] forKey:@"d. 本年数据"];
    //[self.listDict setObject:[NSArray arrayWithArray:tagDatas] forKey:@"e. 标签列表"];
    self.listDictKeys = [[self.listDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listView      = nil;
    self.listDict      = nil;
    self.listDictKeys  = nil;
    self.databaseUtils = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Data Source Methods
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
