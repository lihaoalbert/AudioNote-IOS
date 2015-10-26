//
//  Url.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
#import "BaseModel.h"
/**
 *  api链接统一管理
 */
@interface Url : BaseModel

@property (nonatomic, strong) NSString *base;
@property (nonatomic, strong) NSString *postDevice;
@property (nonatomic, strong) NSString *postData;
@property (nonatomic, strong) NSString *bindWeixin;
@property (nonatomic, strong) NSString *unbindWeixin;
@property (nonatomic, strong) NSString *devices;
@property (nonatomic, strong) NSString *dataList;
@property (nonatomic, strong) NSString *weixinInfo;
@property (nonatomic, strong) NSString *gesturePassword;
@end
