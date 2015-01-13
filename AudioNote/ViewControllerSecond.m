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
    
    // init Utils
    self.databaseUtils   = [[DatabaseUtils alloc] init];
    self.viewCommonUtils = [[ViewCommonUtils alloc] init];
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    //[self.listView setEditing:YES animated:YES];
    // data#limit conflict with dataDate#[distinct strftime('%Y-%m-%d',create_time)]
    self.listData = [self.databaseUtils selectLimit:  100000 Offset: 0];
    
    NSMutableDictionary *dicts = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSMutableDictionary *dict in self.listData) {
        NSString *simple_create_time = dict[@"simple_create_time"];
        [dicts setObject:simple_create_time forKey:simple_create_time];
    }
    self.listDataDate = [[dicts allValues] sortedArrayUsingSelector:@selector(compare:)];
    self.listDataDate = [[self.listDataDate reverseObjectEnumerator] allObjects];
    //NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    //self.listDataDate = [[dicts allValues] sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    self.gBackground = [UIColor blackColor];
    self.gTextcolor  = [UIColor whiteColor];
    self.gHighlightedTextColor  = [UIColor yellowColor];
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
    
    NSString *time = [NSString stringWithFormat:@"%@", [dict objectForKey:@"create_time"]];
    if(time.length == 19) {
        time = [time substringWithRange:NSMakeRange(11, 5)];
    } else {
        time = @"unkown";
    }
    NSLog(@"%lu", (unsigned long)time.length);
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

    cell.cellTime.text = time;
    cell.cellNum.text  = num;
    cell.cellUnit.text = unit;
    cell.cellTag.text  = tag;
    cell.cellDesc.text = [dict objectForKey: @"description"];
    
   
    cell.backgroundColor                 = self.gBackground;
    cell.textLabel.backgroundColor       = self.gBackground;
    cell.detailTextLabel.backgroundColor = self.gBackground;
    cell.cellNum.textColor               = self.gTextcolor;
    cell.cellUnit.textColor              = self.gTextcolor;
    cell.cellTag.textColor               = self.gTextcolor;
    cell.cellDesc.textColor              = self.gTextcolor;
    cell.detailTextLabel.textColor       = self.gTextcolor;
    cell.cellTime.highlightedTextColor   = self.gHighlightedTextColor;
    cell.cellNum.highlightedTextColor    = self.gHighlightedTextColor;
    cell.cellUnit.highlightedTextColor   = self.gHighlightedTextColor;
    cell.cellTag.highlightedTextColor    = self.gHighlightedTextColor;
    cell.cellDesc.highlightedTextColor   = self.gHighlightedTextColor;
    cell.textLabel.highlightedTextColor  = self.gHighlightedTextColor;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = self.gBackground;
    
    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.listDataDate objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[];
}
@end
