//
//  ViewCommonUtils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_ViewCommonUtils_h
#define AudioNote_ViewCommonUtils_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DatabaseUtils.h"



#import "sys/utsname.h"

//https://github.com/tonymillion/Reachability
#import "Reachability.h"


@interface ViewCommonUtils : NSObject



+ (NSString *) httpGet: (NSString *) path;
+ (NSString *) httpPost: (NSURL *) url Data: (NSString *) data;
+ (NSString *) httpPostDevice: (NSString *) data;
+ (NSString *) httpPostDeviceData: (NSString *) data;
+ (NSString *) generateUID;
- (NSDictionary *) dealWithMoney: (NSString *) nMoney;
- (NSDictionary *) dealWithHour: (NSString *) nTime;
- (NSString *) moneyformat: (int) num;

+ (BOOL) isNetworkAvailable;
+ (NSString *) networkType;
+ (NSString*) devicePlatform;
@end


#endif
