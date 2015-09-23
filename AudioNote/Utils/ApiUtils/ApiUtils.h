//
//  ApiUtils.h
//  iLearn
//
//  Created by lijunjie on 15/8/29.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendNSLogFunctionality.h"

@interface ApiUtils : NSObject
+ (NSDictionary *)apiTemplateConfig:(NSString *)apiTempateName;
+ (NSMutableArray *)fieldsNecessary:(NSDictionary *)fields;
+ (BOOL)checkNecessary:(NSDictionary *)dict fields:(NSMutableArray *)fields;
@end
