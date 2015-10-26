//
//  Url+Param.h
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Url.h"
/**
 *  api链接传递参数，约束统一在此
 */
@interface Url (Param)

+ (NSString *)bindWeixin:(NSString *)weixinerUID deviceUID:(NSString *)deviceUID;
+ (NSString *)postData:(NSString *)deviceUID;
+ (NSString *)weixinInfo:(NSString *)weixinerUID;
+ (NSString *)gesturePassword:(NSString *)deviceUID password:(NSString *)password;
@end
