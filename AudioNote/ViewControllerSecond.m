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
    //self.listData = [self.viewCommonUtils getDataListWithDB: self.databaseUtils];
    self.listData = [self.databaseUtils selectDBwithDate];
    
    
    // Gesture
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToThirdView)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToFirstView)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gestureLeft];
    
    // reset UIBarButtonItem
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@""
                                   style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listData = nil;
    self.listView = nil;
    self.databaseUtils = nil;
    self.viewCommonUtils = nil;
}

// Swipe Gesture Functions
-(void)swipeToFirstView
{
    ViewControllerFirst *firstView = [[ViewControllerFirst alloc] init];
    [self.navigationController pushViewController:firstView animated:YES];
    firstView.title = @"小6语记";
}

-(void)swipeToThirdView
{
    ViewControllerThird *thirdView = [[ViewControllerThird alloc] init];
    [self.navigationController pushViewController:thirdView animated:YES];
    thirdView.title = @"数据报表";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];// limit num -
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:self options:nil] lastObject];
    }
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:self options:nil] lastObject];
    
    NSMutableDictionary *dict = [self.listData objectAtIndex:indexPath.row];
    NSString *num  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
    NSString *unit = @"元";
    if ([num isEqualToString: @"0"]) {
        num  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]];
        unit = @"分钟";
    }

    cell.cellNum.text  = num;
    cell.cellUnit.text = unit;
    cell.cellTag.text  = [dict objectForKey: @"category"];
    cell.cellDesc.text = [dict objectForKey: @"description"];
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.listData objectAtIndex:[indexPath row]];
    NSString *alterMsg  = [dict objectForKey: @"description"];
    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"选中的行信息" message:alterMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}
@end
