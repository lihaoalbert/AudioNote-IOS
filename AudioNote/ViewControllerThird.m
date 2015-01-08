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
@property (weak, nonatomic) IBOutlet UITableView    *listView;
@property (nonatomic, nonatomic) NSMutableArray     *listData;
@property (nonatomic, nonatomic) DatabaseUtils      *databaseUtils;
@end

@implementation ViewControllerThird

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // TableView
    self.listView.delegate   = self;
    self.listView.dataSource = self;
    
    //[self.listView setEditing:YES animated:YES];
    self.databaseUtils = [[DatabaseUtils alloc] init];
    self.listData = [self.databaseUtils reportWithType:@"all"];
    
    // Gesture
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToFirstView)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSecondView)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gestureLeft];
    
    
    /*
    // reset UIBarButtonItem
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@""
                                   style:nil target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
     */
}

// Swipe Gesture Functions
-(void)swipeToFirstView {
    ViewControllerFirst *firstView = [[ViewControllerFirst alloc] init];
    [self.navigationController pushViewController:firstView animated:YES];
    firstView.title = @"小6语记";
}

-(void)swipeToSecondView {
    ViewControllerSecond *secondView = [[ViewControllerSecond alloc] init];
    [self.navigationController pushViewController:secondView animated:YES];
    secondView.title = @"明细列表";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

@end
