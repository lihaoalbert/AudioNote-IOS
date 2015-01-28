//
//  ViewControllerSecond.m
//  AudioNote
//
//  Created by weiwang on 14/12/29.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//
// 数据列表:
// 1. 数据列表按日期分组，使用tableView#Group
// 2. tableView#Cell展示界面使用/ViewUtils/MyTableViewCell.xib
//

#import "ViewControllerSecond.h"
#import "ViewControllerFirst.h"
#import "ViewControllerThird.h"
#import "MyTableViewCell.h"

#import "DatabaseUtils.h"
#import "ViewCommonUtils.h"


@interface ViewControllerSecond () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView    *listView;
@property (nonatomic, nonatomic) NSMutableArray     *listData;
@property (nonatomic, nonatomic) NSArray            *listDataDate;
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@property (nonatomic, nonatomic) ViewCommonUtils    *viewCommonUtils;
@property (weak, nonatomic) UIColor                 *gBackground;
@property (weak, nonatomic) UIColor                 *gTextcolor;
@property (weak, nonatomic) UIColor                 *gHighlightedTextColor;
@end

@implementation ViewControllerSecond

@synthesize listView;
@synthesize listData;
@synthesize databaseUtils;
@synthesize viewCommonUtils;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refresh];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.listData        = nil;
    self.listView        = nil;
    self.listDataDate    = nil;
    self.databaseUtils   = nil;
    self.viewCommonUtils = nil;
    self.gBackground    = nil;
    self.gTextcolor     = nil;
    self.gHighlightedTextColor     = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) refresh {
    //self.view.backgroundColor = [UIColor greenColor];
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    //[self.listView setEditing:YES animated:YES];
    
    self.gBackground = [UIColor blackColor];
    self.gTextcolor  = [UIColor whiteColor];
    //self.gHighlightedTextColor  = [UIColor colorWithRed:228.0f/255.0f green:120.0f/255.0f blue:51.0f/255.0f alpha:0.5];
    self.gHighlightedTextColor = [UIColor orangeColor];
    
    
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    
    self.listData = [self.databaseUtils selectLimit: 1000000 Offset: 0 Order: @"id" Format:@""];
    NSLog(@"listData Count: %lu", (unsigned long)[self.listData count]);
    
    NSMutableDictionary *dicts = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSMutableDictionary *dict in self.listData) {
        NSString *simple_create_time = dict[@"simple_create_time"];
        [dicts setObject:simple_create_time forKey:simple_create_time];
    }
    self.listDataDate = [[dicts allValues] sortedArrayUsingSelector:@selector(compare:)];
    self.listDataDate = [[self.listDataDate reverseObjectEnumerator] allObjects];
    
    
    
    [self.listView reloadData];
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listDataDate count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key        = [self.listDataDate objectAtIndex:section];
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dict;
    for(NSInteger i = 0; i < [self.listData count]; i++) {
        dict = [self.listData objectAtIndex: i];
        if([key isEqualToString: dict[@"simple_create_time"]]) {
            [rows addObject: dict];
        }
    }
    
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row     = [indexPath row];
    NSString *key      = [self.listDataDate objectAtIndex:section];
    
    
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dict;
    for(NSInteger i = 0; i < [self.listData count]; i ++) {
        dict = [self.listData objectAtIndex: i];
        if([key isEqualToString: dict[@"simple_create_time"]]) {
            [rows addObject: dict];
        }
    }
    dict = [rows objectAtIndex: row];

    static NSString *cellID = @"cellID";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:self options:nil] lastObject];
    }
    cell.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height + 10);
   
    NSString *tag    = [NSString stringWithFormat:@"%@", [dict objectForKey:@"category"]];
    NSString *nMoney = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
    NSString *nTime  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]];
    
    NSDictionary *dictUtils;
    
    if (![nMoney isEqualToString: @"0"]) {
        
        dictUtils = [self.viewCommonUtils dealWithMoney:nMoney];
        cell.cellMoney.text     = dictUtils[@"nMoney"];
        cell.cellMoneyUnit.text = dictUtils[@"unit"];
        cell.cellMoneyDesc.text = [dict objectForKey: @"description"];
        cell.cellTagLeft.text   = tag;
        cell.cellTime.text      = @"";
        cell.cellTimeUnit.text  = @"";
        cell.cellTimeDesc.text  = @"";
        cell.cellTagRight.text  = @"";
        
    } else if (![nTime isEqualToString:@"0"]) {
        
        dictUtils = [self.viewCommonUtils dealWithHour:nTime];
        cell.cellMoney.text     = @"";
        cell.cellMoneyUnit.text = @"";
        cell.cellMoneyDesc.text = @"";
        cell.cellTagLeft.text   = @"";
        
        cell.cellTime.text     = dictUtils[@"nTime"];
        cell.cellTimeUnit.text = dictUtils[@"unit"];
        cell.cellTimeDesc.text =[dict objectForKey: @"description"];
        cell.cellTagRight.text = tag;

    } else {
        
        cell.cellMoney.text     = @"";
        cell.cellMoneyUnit.text = @"";
        cell.cellMoneyDesc.text = @"";
        cell.cellTagLeft.text   = @"";
        
        cell.cellTime.text     = @"";
        cell.cellTimeUnit.text = @"";
        cell.cellTimeDesc.text = [dict objectForKey: @"input"];
        cell.cellTagRight.text = @"日志";
        
    }
    
    [cell.cellMoney sizeToFit];
    [cell.cellTime sizeToFit];
    
    UIImage *image = [UIImage imageNamed:@"line-1"];
    cell.cellDivider.image  = image;
    cell.cellDivider.center = self.view.center;
 
    cell.backgroundColor                 = self.gBackground;
    cell.textLabel.backgroundColor       = self.gBackground;
    cell.detailTextLabel.backgroundColor = self.gBackground;
    cell.cellMoney.textColor             = self.gTextcolor;
    //cell.cellMoney.highlightedTextColor  = self.gHighlightedTextColor;
    cell.cellMoneyUnit.textColor            = self.gTextcolor;
    //cell.cellMoneyUnit.highlightedTextColor = self.gHighlightedTextColor;
    //cell.textLabel.highlightedTextColor     = self.gHighlightedTextColor;
    cell.selectedBackgroundView             = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    
    [cell.cellMoney setFont:[UIFont systemFontOfSize:16.0]];
    [cell.cellTime setFont:[UIFont systemFontOfSize:16.0]];
    [cell.cellTagLeft setFont:[UIFont systemFontOfSize:16.0]];
    [cell.cellTagRight setFont:[UIFont systemFontOfSize:16.0]];
    [cell.cellMoneyDesc setFont:[UIFont systemFontOfSize:12.0]];
    [cell.cellMoneyUnit setFont:[UIFont systemFontOfSize:12.0]];
    [cell.cellTimeDesc setFont:[UIFont systemFontOfSize:12.0]];
    [cell.cellTimeUnit setFont:[UIFont systemFontOfSize:12.0]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
    return [self.listDataDate objectAtIndex:section];;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}


#pragma mark - <CurrentShow>

- (void)didShowCurrent {
    [self refresh];
    NSLog(@"switch second view.");
}


@end
