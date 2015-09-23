//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHelper.h"

#import "sys/utsname.h"

#import "DatabaseUtils.h"
#import "ViewUtils.h"
#import "HttpUtils.h"
#import "HttpResponse.h"

#define api_device_url @"http://xiao6yuji.com/api/device"
#define api_device_data_url @"http://xiao6yuji.com/api/device/data"

//#define api_device_url @"http://localhost:3000/api/device"
//#define api_device_data_url @"http://localhost:3000/api/device/data"

@interface DataHelper()
@end

@implementation DataHelper


+ (NSString*)devicePlatform {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE:  Machine hardware platform: %@", deviceString);
    return deviceString;
}

+ (NSString *)generateUID {
    // name/os/id/osVersion are necessary.
   NSDictionary *params = @{@"device": @{
                                   @"name": [[UIDevice currentDevice] name],
                                   @"model": [[UIDevice currentDevice] model],
                                   @"localizedModel": [[UIDevice currentDevice] localizedModel],
                                   @"os": [[UIDevice currentDevice] systemName],
                                   @"id": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                   @"osVersion": [[UIDevice currentDevice] systemVersion],
                                   @"platform": [self devicePlatform]
                        }
                 };
    HttpResponse *response = [self httpPostDevice: [NSMutableDictionary dictionaryWithDictionary:params]];
    
    //NSString *idstr = [mutableDictionary2 objectForKey:@"id"];
    NSString *_code = response.data[@"code"];
    NSString *_uid  = response.data[@"info"];
    NSLog(@"code: %@, uid: %@", _code, _uid);
        
    // 将上述数据全部存储到 NSUserDefaults 中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_uid forKey:@"uid"];
    // 这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
    return _uid;
}

+ (NSMutableArray*) getDataListWith:(DatabaseUtils*)databaseUtils
                              Limit: (NSInteger)limit
                             Offset: (NSInteger)offset {
    NSMutableArray *latestDataList = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *dataArray = [databaseUtils selectLimit: limit Offset: offset Order: @"id" Format: @""];
    for(NSDictionary *dict in dataArray) {
        NSString *detail  = @"";
        NSString *pos     = @"right";
        NSString *nTime   = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]];
        NSString *nMoney  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
        NSDictionary *dictUtils;
        
        if (![nMoney isEqualToString:@"0"]) {
            pos    = @"left";
            dictUtils = [ViewUtils dealWithMoney:nMoney];
            detail = [detail stringByAppendingString:dictUtils[@"nMoney"]];
            detail = [detail stringByAppendingFormat:@" %@ - ", dictUtils[@"unit"]];
        }
        else if (![nTime isEqualToString:@"0"]) {
            dictUtils = [ViewUtils dealWithHour:nTime];
            detail = [detail stringByAppendingString:dictUtils[@"nTime"]];
            detail = [detail stringByAppendingFormat:@" %@ - ", dictUtils[@"unit"]];
        }
        else {
            detail = dict[@"input"];
        }
        detail = [detail stringByAppendingString:dict[@"description"]];
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [mutableDictionary setObject:detail forKey:@"detail"];
        [mutableDictionary setObject:[dict objectForKey:@"category"] forKey: @"category"];
        [mutableDictionary setObject:[dict objectForKey:@"id"]   forKey:@"id"];
        [mutableDictionary setObject:pos forKey:@"pos"];
        [mutableDictionary setObject:@"no" forKey:@"moved"];
        [latestDataList addObject:mutableDictionary];
    }
    return latestDataList;
}

+ (HttpResponse *)httpPostDevice:(NSMutableDictionary *)params {
    return [HttpUtils httpPost:api_device_url Params:params];
}

+ (HttpResponse *)httpPostDeviceData:(NSMutableDictionary *)params {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *_uid = [userDefaultes stringForKey:@"uid"];
    if(_uid && [_uid length] > 0) {
        params[@"uid"] = _uid;//[ViewCommonUtils generateUID]
    }
    
    return [HttpUtils httpPost:api_device_data_url Params:params];
}


@end