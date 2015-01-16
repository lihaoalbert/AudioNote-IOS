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
#define api_base_url @"http://xiao6yuji.com/api/ios"
#define RMB_WAN 10000
#define TIME_HOUR 60

// voice record list with format
- (NSMutableArray*) getDataListWith: (DatabaseUtils*) databaseUtils Limit: (NSInteger) limit Offset: (NSInteger) offset {
    NSMutableArray *latestDataList = [NSMutableArray arrayWithCapacity:0];
    
    
    NSMutableArray *dataArray = [databaseUtils selectLimit: limit Offset: offset Order: @"id"];
    for (NSDictionary  *dict in dataArray) {
        NSString *detail = @"";
        NSString *nTime  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nTime"]];
        NSString *nMoney  = [NSString stringWithFormat:@"%@", [dict objectForKey: @"nMoney"]];
        NSDictionary *dictUtils;
        ViewCommonUtils *viewCommonUtils = [[ViewCommonUtils alloc] init];
        
        if (![nMoney isEqualToString:@"0"]) {
            dictUtils = [viewCommonUtils dealWithMoney:nMoney];
            detail = [detail stringByAppendingString:dictUtils[@"nMoney"]];
            detail = [detail stringByAppendingFormat:@" %@ - ", dictUtils[@"unit"]];
        } else if (![nTime isEqualToString:@"0"]) {
            dictUtils = [viewCommonUtils dealWithHour:nTime];
            detail = [detail stringByAppendingString:dictUtils[@"nTime"]];
            detail = [detail stringByAppendingFormat:@" %@ - ", dictUtils[@"unit"]];
        } else {
            detail = dict[@"input"];
        }
        detail = [detail stringByAppendingString:dict[@"description"]];
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [mutableDictionary setObject:detail forKey:@"detail"];
        [mutableDictionary setObject:[dict objectForKey:@"category"] forKey: @"category"];
        [latestDataList addObject:mutableDictionary];
    }
    return latestDataList;
}


/**
 创建识别对象
 domain:识别的服务类型
 iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别
 */
- (id) CreateRecognizer:(id)delegate Domain:(NSString*) domain {
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

- (NSString *) httpGet: (NSString *) path {
    NSString *str         = [api_base_url stringByAppendingFormat:@"?%@", path];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", str);
    NSURL *url            = [NSURL URLWithString:str];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response    = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return response;

}

- (NSString *) httpPost: (NSString *) str {
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Path: %@", str);
    NSURL *url = [NSURL URLWithString:api_base_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return response;
}

// 100000 元 => 10 万元
- (NSDictionary *) dealWithMoney: (NSString *) nMoney {
    NSString *unit = @"元";
    NSInteger iMoney = [nMoney intValue];
    
    if (iMoney > RMB_WAN) {
        nMoney = [NSString stringWithFormat:@"%.3ld", iMoney / RMB_WAN];
        unit   = @"万元";
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:nMoney,@"nMoney",unit,@"unit", nil];
}

// 90 分钟 => 1.5 小时
- (NSDictionary *) dealWithHour: (NSString *) nTime {
    NSString *unit = @"分钟";
    NSInteger iTime = [nTime intValue];
    
    if (iTime > TIME_HOUR) {
        nTime = [NSString stringWithFormat:@"%.1f", roundf(iTime * 10 / TIME_HOUR ) / 10];
        unit   = @"小时";
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:nTime,@"nTime",unit,@"unit", nil];
}

- (NSString *) moneyformat: (int) num {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0"];
    return [numberFormatter stringFromNumber:[NSNumber numberWithInt: num]];
}
@end