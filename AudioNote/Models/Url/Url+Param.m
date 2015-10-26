//
//  Url+Param.m
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url+Param.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"

@implementation Url (Param)

#pragma mark - GET


+ (NSString *)bindWeixin:(NSString *)weixinerUID deviceUID:(NSString *)deviceUID {
    
    NSString *urlString  = [[Url alloc] init].bindWeixin;
    
    return [NSString stringWithFormat:urlString, weixinerUID, deviceUID];
}

+ (NSString *)postData:(NSString *)deviceUID{
    
    NSString *urlString  = [[Url alloc] init].postData;
    urlString = [NSString stringWithFormat:urlString, deviceUID];
    
    return urlString;
}

+ (NSString *)weixinInfo:(NSString *)weixinerUID {
    NSString *urlString = [[Url alloc] init].weixinInfo;
    urlString = [NSString stringWithFormat:urlString, weixinerUID];
    
    return urlString;
}

+ (NSString *)gesturePassword:(NSString *)deviceUID password:(NSString *)password {
    NSString *urlString = [[Url alloc] init].gesturePassword;
    urlString = [NSString stringWithFormat:urlString, deviceUID, password];
    
    return urlString;
}

#pragma mark - GET# assistant methods
+ (NSString *)UrlConcate:(NSString *)url Param:(NSDictionary *)params {
    NSString *paramString = [Url _parameters:params];
    NSString *urlString   = [NSString stringWithFormat:@"%@?%@", url, paramString];
    return urlString;
}


+ (NSString *)_parameters:(NSDictionary *)params {
    NSString *value;
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSString *key in params) {
        value = [params objectForKey:key];
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [paramArray componentsJoinedByString:@"&"];
}

@end
