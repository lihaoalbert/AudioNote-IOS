//
//  ViewControllerSecond.m
//  AudioNote
//
//  Created by weiwang on 14/12/29.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import "ViewControllerSecond.h"
#import "ViewControllerFirst.h"
#import "ViewControllerThird.h"
#import "MyTableViewCell.h"

#import "DatabaseUtils.h"
#import "ViewCommonUtils.h"

@interface ViewControllerSecond () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView    *listView;
@property (nonatomic, nonatomic) NSMutableArray     *listData;
@property (nonatomic, nonatomic) NSMutableArray     *listDataDate;
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@property (nonatomic, nonatomic) ViewCommonUtils    *viewCommonUtils;
@end

@implementation ViewControllerSecond

@synthesize listView;
@synthesize listData;
@synthesize databaseUtils;
@synthesize viewCommonUtils;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    //[self.listView setEditing:YES animated:YES];
    // data#limit conflict with dataDate#[distinct strftime('%Y-%m-%d',create_time)]
    self.listData    = [self.databaseUtils selectLimit:  100000 Offset: 0];
    self.listDataDate = [self.databaseUtils selectSimpleCreateTime];
    NSLog(@"ListData %lu", (unsigned long)self.listData.count);
    NSLog(@"listDataDate %lu", (unsigned long)self.listDataDate.count);
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listData        = nil;
    self.listView        = nil;
    self.listDataDate    = nil;
    self.databaseUtils   = nil;
    self.viewCommonUtils = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSString *tag  = [NSString stringWithFormat:@"%@", [dict objectForKey:@"category"]];
    NSString *num  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
    NSString *unit = @"元";
    if ([num isEqualToString: @"0"]) {
        num  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]];
        unit = @"分钟";
        //tag = [tag stringByAppendingString:@"时间"];
    } else {
        num  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
        unit = @"元";
        //tag = [tag stringByAppendingString:@"金额"];
    }

    cell.cellNum.text  = num;
    cell.cellUnit.text = unit;
    cell.cellTag.text  = tag;
    cell.cellDesc.text = [dict objectForKey: @"description"];
   
    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.listDataDate objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}
@end
