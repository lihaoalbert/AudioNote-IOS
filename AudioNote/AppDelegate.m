//
//  AppDelegate.m
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//
//  IOS 总控制处.
//  功能
//  1. 所有界面实例在此创建放入 viewControllers。
//      viewControllers中界面切换在ViewControllerContainer.m中实现。
//  2. app屏幕是允许横屏，在此设置

#import "AppDelegate.h"
#import "ViewControllerContainer.h"
#import "ViewControllerFirst.h"
#import "ViewControllerSecond.h"
#import "ViewControllerThird.h"
#define myNSLog NSLog
#define IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define kTopBarHeight 44.0
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewControllerContainer *containerController = [[ViewControllerContainer alloc] init];
    self.window.rootViewController         = containerController;
    self.window.backgroundColor            = [UIColor whiteColor];
    ViewControllerFirst *firstController   = [[ViewControllerFirst alloc] init];
    firstController.title                  = @"小6语记";
    ViewControllerSecond *secondController = [[ViewControllerSecond alloc] init];
    secondController.title                 = @"列表";
    ViewControllerThird *thirdController   = [[ViewControllerThird alloc] init];
    thirdController.title                  = @"报表";
    containerController.viewControllers    = [NSMutableArray arrayWithObjects:firstController, secondController, thirdController, nil];
    
    for (UIViewController *viewController in containerController.viewControllers) {
        [viewController.view setContentHuggingPriority:ScreenWidth forAxis:UILayoutConstraintAxisHorizontal];
    }

    [self.window makeKeyAndVisible];


    return YES;
}

// 禁止app横屏， 否则界面会乱掉
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
