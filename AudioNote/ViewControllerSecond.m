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
#import "PopupView.h"


#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height


@interface ViewControllerSecond () <UITableViewDelegate, UITableViewDataSource>
//@property (strong, nonatomic) IBOutlet UITableView  *listView;
@property (nonatomic, strong) PopupView            * popUpView;

@property (nonatomic, nonatomic) NSMutableArray     *listData;
@property (nonatomic, nonatomic) NSArray            *listDataDate;
@property (nonatomic, nonatomic) NSInteger          listDataLimit;
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@property (nonatomic, nonatomic) ViewCommonUtils    *viewCommonUtils;
@property (weak, nonatomic) UIColor                 *gBackground;
@property (weak, nonatomic) UIColor                 *gTextcolor;
@property (weak, nonatomic) UIColor                 *gHighlightedTextColor;
@end

@implementation ViewControllerSecond

//@synthesize listView;
@synthesize listData;
@synthesize listDataDate;
@synthesize databaseUtils;
@synthesize viewCommonUtils;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    [self refreshView];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.listData        = nil;
    self.listDataDate    = nil;
    self.listDataLimit   = 10;
    self.databaseUtils   = nil;
    self.viewCommonUtils = nil;
    self.gBackground    = nil;
    self.gTextcolor     = nil;
    self.gHighlightedTextColor     = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) refreshView {
    //self.view.backgroundColor = [UIColor greenColor];
    
    //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-200.0f) style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    
    self.gBackground = [UIColor blackColor];
    self.gTextcolor  = [UIColor whiteColor];
    //self.gHighlightedTextColor  = [UIColor colorWithRed:228.0f/255.0f green:120.0f/255.0f blue:51.0f/255.0f alpha:0.5];
    self.gHighlightedTextColor = [UIColor orangeColor];
    
    
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    
    
    self.listDataLimit  = 10;
    self.listData = [self.databaseUtils selectLimit: self.listDataLimit Offset: 0 Order: @"id" Format:@""];
    self.listDataDate = [self getListDataDate:self.listData];
    NSLog(@"listData Count: %lu", (unsigned long)[self.listData count]);
    
    self.popUpView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4)];
    
    self.popUpView.ParentView = self.view;
    
    [self.tableView reloadData];
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
        
        cell.cellDivider.tag    = 1; //该cell类型 1: 金额, 2: 时间, 3:日志
        dictUtils = [self.viewCommonUtils dealWithMoney:nMoney];
        cell.cellMoney.text     = dictUtils[@"nMoney"];
        //cell.cellMoneyDesc.backgroundColor = [UIColor orangeColor];
        cell.cellMoneyUnit.text = dictUtils[@"unit"];
        cell.cellMoneyDesc.text = [dict objectForKey: @"description"];
        cell.cellTagLeft.text   = tag;
        cell.cellTime.text      = @"";
        cell.cellTime.tag       = 0; //平移状态, 0:未动， 1:平移
        cell.cellTimeUnit.text  = @"";
        cell.cellTimeDesc.text  = @"";
        cell.cellTagRight.text  = @"";
        
    } else if (![nTime isEqualToString:@"0"]) {
        
        cell.cellDivider.tag    = 2;
        dictUtils = [self.viewCommonUtils dealWithHour:nTime];
        cell.cellMoney.text     = @"";
        cell.cellMoney.tag      = 0; //平移状态, 0:未动， 1:平移
        cell.cellMoneyUnit.text = @"";
        cell.cellMoneyDesc.text = @"";
        cell.cellTagLeft.text   = @"";
        
        cell.cellTime.text     = dictUtils[@"nTime"];
        cell.cellTimeUnit.text = dictUtils[@"unit"];
        cell.cellTimeDesc.text = [dict objectForKey: @"description"];
        cell.cellTagRight.text = tag;

    } else {
        
        cell.cellDivider.tag    = 3;
        cell.cellMoney.text     = @"";
        cell.cellMoneyUnit.text = @"";
        cell.cellMoneyDesc.text = @"";
        cell.cellTagLeft.text   = @"";
        
        cell.cellTime.text     = @"";
        cell.cellTime.tag      = 0; //平移状态, 0:未动， 1:平移
        cell.cellTimeUnit.text = @"";
        cell.cellTimeDesc.text = [dict objectForKey: @"input"];
        cell.cellTagRight.text = @"日志";
        
    }
    
    //[cell.cellMoney sizeToFit];
    cell.cellMoney.textAlignment = NSTextAlignmentRight;
    cell.cellTime.textAlignment = NSTextAlignmentRight;
 
    
    UIImage *image = [UIImage imageNamed:@"timeline"];
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
    
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
    [cell addGestureRecognizer:gesture];
    
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    headerView.backgroundColor = [UIColor blackColor];

    UILabel *headerLabel = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    return [self.listDataDate objectAtIndex:section];;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}


#pragma mark - <CurrentShow>

- (void)didShowCurrent {
    [self refreshView];
    NSLog(@"switch second view.");
}


#pragma mark - <PullReflash>

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

- (void)addItem {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    mutableArray = [self.databaseUtils selectLimit: self.listDataLimit Offset: self.listData.count Order: @"id" Format:@""];

    if(mutableArray.count > 0) {
        for(NSInteger i=0; i<mutableArray.count; i++)
            [self.listData addObject:[mutableArray objectAtIndex:i]];
        
        self.listDataDate = [self getListDataDate:self.listData];
        [self.tableView reloadData];
        //TODO 向下滑动后，tableView置底，下面代码无效
        //[self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height-ScreenHeight) animated:NO];
    } else {
        //没有更多内容了
        self.hasMore = NO;
    }
        NSLog(@"Offset: %li, Limit: %li, Data: %lu", (long)self.listDataLimit, (unsigned long)mutableArray.count, (long)self.listData.count);
    
    [self stopLoading];
}


#pragma mark - <LongPress>

- (void) handleTableViewCellLongPress:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state != UIGestureRecognizerStateBegan)
        return;
    
    MyTableViewCell *myCell = (MyTableViewCell *)gesture.view;
    switch(myCell.cellDivider.tag) {
        case 1:  // 金额
            [ViewCommonUtils myCellMoney: myCell];
            break;
        case 2:  // 时间
            [ViewCommonUtils myCellTime: myCell];
            break;
        default: // 日志
            [ViewCommonUtils myCellTime: myCell];
            break;
    };
}

- (NSArray *)getListDataDate: (NSMutableArray *)_listData {
    NSMutableDictionary *dicts = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSMutableDictionary *dict in _listData) {
        NSString *simple_create_time = dict[@"simple_create_time"];
        [dicts setObject:simple_create_time forKey:simple_create_time];
    }
    NSArray *_listDataDate;
    _listDataDate = [[dicts allValues] sortedArrayUsingSelector:@selector(compare:)];
    _listDataDate = [[_listDataDate reverseObjectEnumerator] allObjects];
    return _listDataDate;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // [super setSelected:selected animated:animated];
    if (selected) {
    } else {
    }
}*/

@end
