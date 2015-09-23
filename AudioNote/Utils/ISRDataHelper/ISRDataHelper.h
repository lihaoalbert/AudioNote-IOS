//
//  ISRDataHander.h
//  MSC
//
//  Created by ypzhao on 12-11-19.
//  Copyright (c) 2012年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyUserWords.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "iflyMSC/IFlySetting.h"

// 云端返回数据解析类
@protocol ISRDataHelper<NSObject>

//解析听写json格式的数据
- (NSString *) getResultFromJson:(NSString*)params;

//解析命令词返回的结果
- (NSString*) getResultFormAsr:(NSString*)params;

//解析语法识别返回的结果
-(NSString *) getResultFromABNFJson:(NSString*)params;

@end

@interface ISRDataHelper : NSObject<ISRDataHelper>

+ (id) shareInstance;
/*
 * @ 创建识别对象
 <Param name=delegate> object which implement IFlySpeechRecognizerDelegate</Param>
 <Param name=domain> domain:iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别;</Param>
 */
+ (id)CreateRecognizer:(id)delegate Domain:(NSString*)domain;
@end
