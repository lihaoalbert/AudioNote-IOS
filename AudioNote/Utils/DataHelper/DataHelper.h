//
//  ApiUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DataHelper_h
#define iSearch_DataHelper_h
#import <UIKit/UIKit.h>

@class DatabaseUtils;
@class HttpResponse;

/**
 *  处理数据: ApiHelper + CacheHelper
 */
@interface DataHelper : NSObject

+ (NSMutableArray*) getDataListWith:(DatabaseUtils*)databaseUtils
                              Limit: (NSInteger)limit
                             Offset: (NSInteger)offset;

+ (NSMutableDictionary *)postDevice;

+ (NSMutableDictionary *)bindWeixin:(NSString *)weixinerUID;

+ (NSMutableDictionary *)getWeixinInfo:(NSString *)weixinerUID;

+ (void)postData;
+ (void)postGesturePassword;
@end

#endif
