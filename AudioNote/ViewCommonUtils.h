//
//  ViewCommonUtils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_ViewCommonUtils_h
#define AudioNote_ViewCommonUtils_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DatabaseUtils.h"

#import "iflyMSC/IFlySpeechRecognizerDelegate.h"

#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyUserWords.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"


@interface ViewCommonUtils : NSObject

- (NSMutableArray*) getDataListWith: (DatabaseUtils*) databaseUtils Limit: (NSInteger) limit Offset: (NSInteger) offset;
- (void)switchViewController: (UIViewController*) viewControllers
                        From: (UIViewController*) fromViewController
                          to: (UIViewController*) toViewController;

/*
 * @ 创建识别对象
 <Param name=delegate> object which implement IFlySpeechRecognizerDelegate</Param>
 <Param name=domain> domain:iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别;</Param>
 */
-(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain;

@end


#endif
