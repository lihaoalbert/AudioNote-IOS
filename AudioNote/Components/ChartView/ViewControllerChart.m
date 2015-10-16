//
//  ViewController.m
//  DrawGraphic
//
//  Created by wu on 14-11-12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ViewControllerChart.h"
#import "GraphicView.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewControllerChart ()

@end

@implementation ViewControllerChart

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawChart];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) drawChart {
    GraphicView *g = [[GraphicView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    // g.backgroundColor = [UIColor whiteColor];
    g.backgroundColor = [UIColor clearColor];
    [g loadFromDB];
    [self.view addSubview:g];
    
}


#pragma mark - <CurrentShow>

- (void)didShowCurrent {
    [self drawChart];
    NSLog(@"switch to first view.");
}

@end
