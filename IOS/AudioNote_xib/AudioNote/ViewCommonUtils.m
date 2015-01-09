//
//  ViewCommonUtils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  the functions that called more than two pages will put here.

#import "ViewCommonUtils.h"

@implementation ViewCommonUtils
#define myNSLog 

// voice record list with format
- (NSMutableArray*) getDataListWithDB: (DatabaseUtils*) databaseUtils {
    NSMutableArray *latestDataList = [NSMutableArray arrayWithCapacity:0];//[[NSMutableArray alloc] initWithObjects:@"first",@"two",@"three",nil];
    
    
    NSMutableArray *dataArray = [databaseUtils selectDBwithDate];
    NSLog(@"Record Row Count: %lu", dataArray.count);
    for (NSDictionary  *dict in dataArray) {
        NSString *listItem = dict[@"description"];
        listItem = [listItem stringByAppendingString:@"["];
        listItem = [listItem stringByAppendingString:[NSString stringWithFormat:@"%@",dict[@"nMoney"]]];
        listItem = [listItem stringByAppendingString:@"元 ]["];
        listItem = [listItem stringByAppendingString:[NSString stringWithFormat:@"%@",dict[@"nTime"]]];
        listItem = [listItem stringByAppendingString:@"分钟]"];
        [latestDataList addObject:listItem];
        for(NSString *key in dict) {
            myNSLog(@"%10@: %@", key, dict[key]);
        }
    }
    return latestDataList;
}

- (void)switchViewController: (UIViewController*) viewControllers
                        From: (UIViewController*) fromViewController
                          to: (UIViewController*) toViewController {
    /*
    Class FromViewControllerClass = [fromViewController class];
    Class ToViewControllerClass   = [toViewController class];
    UIViewController* vc;
    for (vc in viewControllers) {
        if ([vc isKindOfClass:FromViewControllerClass]) {
            FromViewControllerClass *dpvc = (FromViewControllerClass *)vc;
            [dpvc bannerHide];
            break;
        }
    }
    
    for (vc in viewControllers) {
        if ([vc isKindOfClass: ToViewControllerClass]) {
            [fromViewController popToRootViewControllerAnimated:NO];
            [fromViewController pushViewController:vc animated:YES];
            break;
        }
    }*/
}

/**
 创建识别对象
 domain:识别的服务类型
 iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别
 */
-(id) CreateRecognizer:(id)delegate Domain:(NSString*) domain {
    IFlySpeechRecognizer * iflySpeechRecognizer = nil;
    
    // 创建识别对象
    iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    
    //请不要删除这句,createRecognizer是单例方法，需要重新设置代理
    iflySpeechRecognizer.delegate = delegate;
    
    [iflySpeechRecognizer setParameter:domain forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //设置采样率
    //    [iflySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置录音保存文件
    //    [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    //设置为非语义模式
    //[iflySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
    
    //设置返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [iflySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //设置为麦克风输入模式
    [iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    return iflySpeechRecognizer;
}


@end