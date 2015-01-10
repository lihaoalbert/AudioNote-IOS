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
@property (nonatomic, nonatomic) NSMutableArray       *listData;
@property (nonatomic, nonatomic) NSMutableDictionary  *listDict;
@property (nonatomic, nonatomic) DatabaseUtils        *databaseUtils;
@end

@implementation ViewControllerThird
@synthesize listData;
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
    self.listData = [self.databaseUtils reportWithType:@"all"];
    
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
    //[self.listDict setObject:[NSArray arrayWithArray:tagDatas] forKey:@"标签列表"];
    
    // Gesture
    /*
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToFirstView)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSecondView)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gestureLeft];
    */
    
    /*
    // reset UIBarButtonItem
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@""
                                   style:nil target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
     */
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listData = nil;
    self.listView = nil;
    self.databaseUtils = nil;
}

// Swipe Gesture Functions
-(void)swipeToFirstView {
    ViewControllerFirst *firstView = [[ViewControllerFirst alloc] init];
    [self.navigationController pushViewController:firstView animated:YES];
    firstView.title = @"小6语记";
    //[self.navigationController popToViewController:firstView animated:YES];
}

-(void)swipeToSecondView {
    ViewControllerSecond *secondView = [[ViewControllerSecond alloc] init];
    [self.navigationController pushViewController:secondView animated:YES];
    secondView.title = @"明细列表";
    //[self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //这个方法用来告诉表格有几个分组
    return [[self.listDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //这个方法告诉表格第section个分组有多少行
    NSString *key  = [[self.listDict allKeys] objectAtIndex:section];
    NSArray  *rows = (NSArray *)[self.listDict objectForKey:key];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //这个方法用来告诉某个分组的某一行是什么数据，返回一个UITableViewCell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    
    NSString *key  = [[self.listDict allKeys] objectAtIndex:section];
    NSArray  *rows = (NSArray *)[self.listDict objectForKey:key];
    
    static NSString *GroupedTableIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             GroupedTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:GroupedTableIdentifier];
    }
    
    //给Label附上城市名称  key 为：C_Name
    cell.textLabel.text = [rows objectAtIndex:row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //这个方法用来告诉表格第section分组的名称
    NSString *key  = [[self.listDict allKeys] objectAtIndex:section];
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}



/*
#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    NSMutableDictionary *dict = [self.listData objectAtIndex:indexPath.row];
    NSString *text  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
    text  = [text stringByAppendingString: @"元"];
    text  = [text stringByAppendingString: [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]]];
    text  = [text stringByAppendingString: @"分钟"];
    text  = [text stringByAppendingString: [NSString stringWithFormat:@"%@", [dict objectForKey: @"category"]]];
 
    NSLog(@"%@", text);
    cell.textLabel.text = text;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [self.listData objectAtIndex:[indexPath row]];
    NSString *alterMsg  = [dict objectForKey: @"category"];
    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"选中的行信息" message:alterMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}
*/
@end
