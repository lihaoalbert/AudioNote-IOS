//
//  ApiUtils.m
//  iLearn
//
//  Created by lijunjie on 15/8/29.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ApiUtils.h"
#import "FileUtils.h"

@implementation ApiUtils
+ (NSDictionary *)apiTemplateConfig:(NSString *)apiTempateName {
    NSString *apiTemplatePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:apiTempateName];
    NSDictionary *apiConfig = [FileUtils readConfigFile:apiTemplatePath];
    return apiConfig;
}
+ (NSMutableArray *)fieldsNecessary:(NSDictionary *)fields {
    NSMutableArray *fieldsNeed = [NSMutableArray array];
    NSEnumerator *keyEnumerator = [fields keyEnumerator];
    NSString *key;
    while(key = [keyEnumerator nextObject]) {
        if(fields[key] && [fields[key] isEqualToString:@"1"]) {
            [fieldsNeed addObject:key];
        }
    }
    return fieldsNeed;
}
+ (BOOL)checkNecessary:(NSDictionary *)dict fields:(NSMutableArray *)fields {
    BOOL isAvailable = YES;
    for(NSString *field in fields) {
        if(!dict[field]) {
            isAvailable = NO;
            break;
        }
    }
    if(!isAvailable) {
        ActionLogRecord(@"API", @"数据字段不全", @"", (@{@"necessary fields": fields, @"server data": dict}));
    }
    return isAvailable;
}
@end
