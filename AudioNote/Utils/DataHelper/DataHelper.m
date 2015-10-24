//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHelper.h"
#import "DatabaseUtils.h"
#import "ViewUtils.h"
#import "HttpUtils.h"
#import "HttpResponse.h"
#import "Version.h"
#import "Url+Param.h"
#import "FileUtils.h"
#import "const.h"


@interface DataHelper()
@end

@implementation DataHelper


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


+ (NSMutableDictionary *)postDevice {
    NSDictionary *params = @{@"device": @{
                                     @"name": [[UIDevice currentDevice] name],
                                     @"model": [[UIDevice currentDevice] model],
                                     @"localizedModel": [[UIDevice currentDevice] localizedModel],
                                     @"os": [[UIDevice currentDevice] systemName],
                                     @"id": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                     @"osVersion": [[UIDevice currentDevice] systemVersion],
                                     @"platform": [Version machineHuman]
                                     }
                             };
    HttpResponse *response = [HttpUtils httpPost:[[Url alloc] init].postDevice Params:[NSMutableDictionary dictionaryWithDictionary:params]];
    
    NSString *deviceConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:DEVICE_CONFIG_FILENAME];
    [FileUtils writeJSON:response.data Into:deviceConfigPath];
    
    return response.data;
}

+ (NSMutableDictionary *)bindWeixin:(NSString *)weixinerUID {
    NSString *deviceConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:DEVICE_CONFIG_FILENAME];
    NSDictionary *deviceConfig = [FileUtils readConfigFile:deviceConfigPath];
    NSString *deviceUID = deviceConfig[@"device_uid"];
    NSString *bindWeixinUrl = [Url bindWeixin:weixinerUID deviceUID:deviceUID];
    
    HttpResponse *response = [HttpUtils httpPost:bindWeixinUrl Params:[NSMutableDictionary dictionary]];
    
    NSString *weixinBindDevice = [FileUtils dirPath:CONFIG_DIRNAME FileName:WEIXIN_BIND_DEVICE_FILENAME];
    [FileUtils writeJSON:response.data Into:weixinBindDevice];
    
    return response.data;
}

+ (NSMutableDictionary *)getWeixinInfo:(NSString *)weixinerUID {
    NSString *weixinerInfoUrl = [Url weixinInfo:weixinerUID];
    HttpResponse *response = [HttpUtils httpGet:weixinerInfoUrl];

    NSString *weixinerInfoConfigPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:WEIXINER_CONFIG_FILENAME];
    [FileUtils writeJSON:response.data Into:weixinerInfoConfigPath];
    
    return response.data;
}

@end