//
//  ViewControllerContainer.m
//  AudioNote
//
//  Created by lijunjie on 15-1-10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
// 当前有三个界面, 放在一个容器里面，此文件为容器处理。（容器类型: scrollView)

#import "ViewControllerContainer.h"
#import "NSMutableArray+Util.h"
#import "ContainerTopBar.h"
#import "DidShowCurrent.h"
#import "FileUtils.h"
#import "DataHelper.h"
#import "HttpUtils.h"
#import "const.h"
// http://www.dreamingwish.com/frontui/article/default/uiscrollview-infinite-loop-scrolling.html
#define IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define kTopBarHeight 44.0
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewControllerContainer() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) ContainerTopBar *topBar;
@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) CGFloat pageHeight;
@property (nonatomic, assign) UIViewController<DidShowCurrent> *currentController;
@end

@implementation ViewControllerContainer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (id)init {
    self = [super init];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    int interval = 60 * 10;
    NSDate *now = [NSDate date];
    NSInteger timeInterval = [now timeIntervalSince1970];
    NSInteger nextMinuteInterval = ((timeInterval / interval) + 1) * interval;
    NSDate *fireDate = [NSDate dateWithTimeIntervalSince1970:nextMinuteInterval];
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:interval
                                                target:self
                                              selector:@selector(actionPushDataToServer)
                                              userInfo:nil
                                               repeats:YES];
    
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)actionPushDataToServer {
    NSLog(@"actionPushDataToServer - %@", [NSDate date]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![HttpUtils isNetworkAvailable]) {
            return;
        }
        
        NSString *settingsConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:SETTINGS_CONFIG_FILENAME];
        NSDictionary *settingsInfo = [FileUtils readConfigFile:settingsConfigPath];
        if(settingsInfo && [settingsInfo[@"auto_push_data_to_server"] isEqualToNumber:@1]) {
            [DataHelper postData];
        }
        
        if(settingsInfo && [settingsInfo[@"gesture_password_is_synced"] isEqualToNumber:@0]) {
            [DataHelper postGesturePassword];
        }
    });
}
- (void)initUI {
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
    [self.view setContentHuggingPriority:ScreenWidth forAxis:UILayoutConstraintAxisHorizontal];

    // 1. 用一个临时变量保存返回值。
    CGRect temp = self.view.frame;
    // 2. 给这个变量赋值。因为变量都是L-Value，可以被赋值
    temp.size.height = ScreenHeight;
    temp.size.width = ScreenWidth;
    // 3. 修改frame的值
    self.view.frame = temp;
    

    //NSLog(@"screenWidth: %f, Height:%f", ScreenWidth, ScreenHeight);
    // UIScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kTopBarHeight,CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kTopBarHeight)];
    self.scrollView.delegate      = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces       = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 

    
    [self.view addSubview:self.scrollView];
    
    // ContainerTopBar
    self.topBar = [[ContainerTopBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), kTopBarHeight)];
    self.topBar.backgroundColor  = [UIColor clearColor];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.font             = [UIFont systemFontOfSize:12.0];
    self.topBar.textColor        = [UIColor lightGrayColor];
    self.topBar.textAlignment    = NSTextAlignmentCenter;
    self.topBar.frame            = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), kTopBarHeight);
    [self.view addSubview:self.topBar];
}

- (void)setViewControllers:(NSMutableArray *)viewControllers {
    _viewControllers = [NSMutableArray arrayWithArray:viewControllers];
    
    for (UIViewController *viewController in viewControllers) {
        [viewController willMoveToParentViewController:self];
        viewController.view.frame = CGRectMake(0.0, kTopBarHeight, ScreenWidth, self.view.bounds.size.height-kTopBarHeight);
        [self.scrollView addSubview:viewController.view];
        
        [viewController didMoveToParentViewController:self];
    }
    
    self.topBar.text = [[_viewControllers valueForKey:@"title"] firstObject];
    _currentController = _viewControllers.firstObject;
    
    [self layoutSubViewsWithDirection:kMoveDirectionRight];
}




/*
- (void)layoutSubViews {
    CGFloat x = 0.0;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, self.pageWidth, self.pageHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize   = CGSizeMake(x, self.pageWidth);
    self.scrollView.contentOffset = CGPointMake(self.pageWidth, 0);
}*/
- (void)layoutSubViewsWithDirection:(MoveDirection)direction
{
    /**
     * Step 1: 重排数组索引
     * Step 2: 根据重排好的数组重排子视图frame
     * Step 3: 设置scrollView的contentOffset以正确显示
     */
    direction == kMoveDirectionLeft ? [self.viewControllers moveLeft] : [self.viewControllers moveRight];
    CGFloat x = 0.0;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, ScreenWidth, self.pageHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }

    self.scrollView.contentSize = CGSizeMake(x, self.pageWidth);
    
    switch (direction) {
        case kMoveDirectionLeft:
            self.scrollView.contentOffset = CGPointMake(self.pageWidth*(self.viewControllers.count-2), 0);
            break;
        case kMoveDirectionRight:
            self.scrollView.contentOffset = CGPointMake(self.pageWidth, 0);
            break;
        default:
            break;
    }
}


- (CGFloat)pageWidth {
    return CGRectGetWidth(self.scrollView.frame);
}

- (CGFloat)pageHeight {
    return CGRectGetHeight(self.view.frame) - kTopBarHeight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - <UIScrollViewDelegate>

// 滑动结束后回调
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // self.scrollView.userInteractionEnabled = YES;
    // [self refresh];
    
    NSUInteger currentPage = self.scrollView.contentOffset.x / self.pageWidth;
    self.topBar.text = [[_viewControllers valueForKey:@"title"] objectAtIndex:currentPage];
    
    if (currentPage == self.viewControllers.count-1) { // 移到了最右边
        [self layoutSubViewsWithDirection:kMoveDirectionLeft];
        self.currentController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
    } else if (currentPage == 0) { // 移到了最左边
        [self layoutSubViewsWithDirection:kMoveDirectionRight];
        self.currentController = [self.viewControllers objectAtIndex:2];
    }
    
    currentPage = self.scrollView.contentOffset.x / self.pageWidth;
    self.currentController = [self.viewControllers objectAtIndex:currentPage];
}

- (void)setCurrentController:(UIViewController<DidShowCurrent> *)currentController
{
    if (_currentController != currentController) {
        _currentController = currentController;
        [_currentController didShowCurrent];
    }
}

/** 为了实现循环滚动，要重新排版每个view的frame, 要重新排版就要对数组中引用的对象指针进行排列
 *  思路：当移动到最末尾的时候（self.scrollView.contentOffset.x到达最大），改变数组中指针排序，并调用layoutSubViews重新排版
 比如排版为：红绿蓝紫，假设当前页是紫色页，更改数组指针，让紫色变为第二个页面，即：调成绿紫蓝红，并调用setContentOffSet为pageWidth, 0 显示紫色
 同理，当移动到最开始的也对指针进行排序
 */
/**
 - (void)refresh
 {
 NSUInteger currentPage = self.scrollView.contentOffset.x / self.pageWidth;
 self.topBar.text = [[_viewControllers valueForKey:@"title"] objectAtIndex:currentPage];
 if (currentPage == self.viewControllers.count-1) { // 移到了最右边的view
 [self.viewControllers moveRightStep:2];
 [self layoutSubViews];
 return;
 }
 if (currentPage == 0) {
 [self.viewControllers moveRight];
 [self layoutSubViews];
 return;
 }
 }
 */

#if 0
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = NO;
}
#endif

@end
