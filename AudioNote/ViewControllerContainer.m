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
// http://www.dreamingwish.com/frontui/article/default/uiscrollview-infinite-loop-scrolling.html
#define IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define kTopBarHeight 44.0

@interface ViewControllerContainer() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) ContainerTopBar *topBar;
@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) CGFloat pageHeight;

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
}

- (void)initUI {
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
    // UIScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kTopBarHeight,CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kTopBarHeight)];
    self.scrollView.delegate      = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces       = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    // ContainerTopBar
    self.topBar                  = [[ContainerTopBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), kTopBarHeight)];
    self.topBar.font             = [UIFont systemFontOfSize:16.0];
    self.topBar.backgroundColor  = [UIColor blackColor];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.font             = [UIFont systemFontOfSize:20.0];
    self.topBar.textColor        = [UIColor whiteColor];
    self.topBar.textAlignment    = NSTextAlignmentCenter;
    self.topBar.frame            = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), kTopBarHeight);
    self.view.backgroundColor    = [UIColor blackColor];
    [self.view addSubview:self.topBar];
}

- (void)setViewControllers:(NSMutableArray *)viewControllers {
    _viewControllers = [NSMutableArray arrayWithArray:viewControllers];

    for (UIViewController *viewController in viewControllers) {
        [viewController willMoveToParentViewController:self];
        viewController.view.frame = CGRectMake(0.0, kTopBarHeight, CGRectGetWidth(self.scrollView.frame), self.view.bounds.size.height-kTopBarHeight);;
        NSLog(@"viewController: %@", viewController);
        NSLog(@"width: %f", CGRectGetWidth(self.scrollView.frame));
        NSLog(@"width: %f", viewController.view.bounds.size.width);
        [self.scrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
    [self refresh];
}

- (void)layoutSubViews {
    CGFloat x = 0.0;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, self.pageWidth, self.pageHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize   = CGSizeMake(x, self.pageWidth);
    self.scrollView.contentOffset = CGPointMake(self.pageWidth, 0);
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // self.scrollView.userInteractionEnabled = YES;
    //NSLog(@"before refresh");
    [self refresh];
}

/** 为了实现循环滚动，要重新排版每个view的frame, 要重新排版就要对数组中引用的对象指针进行排列
 *  思路：
        当移动到最末尾的时候（self.scrollView.contentOffset.x到达最大），改变数组中指针排序，并调用layoutSubViews重新排版
        比如排版为：[红绿蓝紫]，假设当前页是[紫色]页，更改数组指针，让[紫色]变为第二个页面，即：调成[绿紫蓝红]，并调用setContentOffSet为pageWidth, 0 显示紫色
        同理，当移动到最开始的也对指针进行排序
 */
- (void)refresh {
    NSUInteger currentPage  = self.scrollView.contentOffset.x / self.pageWidth;
    NSLog(@"offset: %f, width: %f, move:%lu", self.scrollView.contentOffset.x , self.pageWidth, (unsigned long)currentPage);
    NSUInteger viewCount    = [self.viewControllers count];
    self.topBar.text = [[_viewControllers valueForKey:@"title"] objectAtIndex:currentPage];
    if (currentPage == viewCount-1) { // 移到了最右边的view
        [self.viewControllers moveRightStep:2];
        [self layoutSubViews];
        return;
    }
    if (currentPage == 0) {
        [self.viewControllers moveRight];
        //NSLog(@"%@", [self.viewControllers lastObject]);
        [self layoutSubViews];
    }
}

#if 0
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollView.userInteractionEnabled = NO;
}
#endif

@end
