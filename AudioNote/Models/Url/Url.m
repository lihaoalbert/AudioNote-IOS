//
//  Url.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url.h"
#import "const.h"

@implementation Url

- (Url *)init {
    if(self = [super init]) {
        _base          = BASE_URL;
        _postDevice    = [self concate:@"device"];
        _postData      = [self concate:@"device/%@/data"];
        _bindWeixin    = [self concate:@"weixiner/%@/bind/%@/device"];
        _unbindWeixin  = [self concate:@"weixiner/%@/unbind/%@/device"];
        _devices       = [self concate:@"weixiner/%@/devices"];
        _dataList      = [self concate:@"weixiner/%@/data_list"];
        _weixinInfo    = [self concate:@"weixiner/%@/info"];
        _gesturePassword    = [self concate:@"device/%@/gesture_password/%@"];
    }
    return self;
}

#pragma mark - class methods

#pragma mark - asisstant methods
- (NSString *)concate:(NSString *)path {
    NSString *splitStr  = ([path hasPrefix:@"/"] ? @"" : @"/");
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@%@", BASE_URL, BASE_PATH, splitStr, path];
    return  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
