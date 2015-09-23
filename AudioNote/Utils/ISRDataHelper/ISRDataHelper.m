//
//  ISRDataHander.m
//  MSC
//
//  Created by ypzhao on 12-11-19.
//  Copyright (c) 2012年 iflytek. All rights reserved.
//

#import "ISRDataHelper.h"
#import <SBJson4.h>

#import "iflyMSC/IFlySpeechRecognizerDelegate.h"



static ISRDataHelper *ISRdataHander = nil;
@implementation ISRDataHelper


/**
 创建识别对象
 domain:识别的服务类型
 iat,search,video,poi,music,asr;iat,普通文本听写; search,热词搜索;video,视频音乐搜索;asr: 关键词识别
 */
+ (id)CreateRecognizer:(id)delegate Domain:(NSString*)domain {
    IFlySpeechRecognizer * iflySpeechRecognizer = nil;
    
    // 创建识别对象
    iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    //请不要删除这句,createRecognizer是单例方法，需要重新设置代理
    iflySpeechRecognizer.delegate = delegate;
    
    [iflySpeechRecognizer setParameter:domain forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    //设置采样率
    // [iflySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    //设置录音保存文件
    // [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //设置为非语义模式
    // [iflySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
    //设置返回结果的数据格式，可设置为json，xml，plain，默认为json。
    [iflySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //设置为麦克风输入模式
    [iflySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    return iflySpeechRecognizer;
}

+ (id) shareInstance
{
    if (!ISRdataHander) {
        ISRdataHander = [[ISRDataHelper alloc] init];
    }
    return ISRdataHander;
}

// 解析命令词返回的结果
- (NSString*) getResultFormAsr:(NSString*)params
{
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSString *inputString = nil;
    
	NSArray *array = [params componentsSeparatedByString:@"\n"];

	for (int  index = 0; index < array.count; index++)
	{
        NSRange range;
		NSString *line = [array objectAtIndex:index];
		
		NSRange idRange = [line rangeOfString:@"id="];
        NSRange nameRange = [line rangeOfString:@"name="];
		NSRange confidenceRange = [line rangeOfString:@"confidence="];
		NSRange grammarRange = [line rangeOfString:@" grammar="];
        
        NSRange inputRange = [line rangeOfString:@"input="];
        
		if (confidenceRange.length == 0 || grammarRange.length == 0 || inputRange.length == 0 )
		{
			continue;
		}
        
        //check nomatch
        if (idRange.length!=0) {
            NSUInteger idPosX = idRange.location + idRange.length;
            NSUInteger idLength = nameRange.location - idPosX;
            range = NSMakeRange(idPosX,idLength);
            NSString *idValue = [[line substringWithRange:range]
                                 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            if ([idValue isEqualToString:@"nomatch"]) {
                return @"";
            }
        }
		
        //Get Confidence Value
        NSUInteger confidencePosX = confidenceRange.location + confidenceRange.length;
        NSUInteger confidenceLength = grammarRange.location - confidencePosX;
        range = NSMakeRange(confidencePosX,confidenceLength);
        
        
        NSString *score = [line substringWithRange:range];
        
        NSUInteger inputStringPosX = inputRange.location + inputRange.length;
        NSUInteger inputStringLength = line.length - inputStringPosX;
        
        range = NSMakeRange(inputStringPosX , inputStringLength);
        inputString = [line substringWithRange:range];

        [resultString appendFormat:@"%@ 置信度%@\n",inputString, score];
	}
	
    return resultString;

}

/**
 解析听写json格式的数据
 params例如：
 {"sn":1,"ls":true,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"w":"白日","sc":0}]},{"bg":0,"cw":[{"w":"依山","sc":0}]},{"bg":0,"cw":[{"w":"尽","sc":0}]},{"bg":0,"cw":[{"w":"黄河入海流","sc":0}]},{"bg":0,"cw":[{"w":"。","sc":0}]}]}
 */
-(NSString *) getResultFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];

    //返回的格式必须为utf8的,否则发生未知错误
    NSString *jsonString = params;
    
    id block = ^(id obj, BOOL *ignored) {
        NSDictionary *dic = obj;
        
        NSArray *wordArray = [dic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }

    };
    
    id eh = ^(NSError *err) {
        NSLog(@"json parser error");
        //        self.output.string = err.description;
    };
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    [parser parse:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    return tempStr;
}

/**
 解析语法识别返回的结果
 */
-(NSString *) getResultFromABNFJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    
    //返回的格式必须为utf8的,否则发生未知错误
    NSString *jsonString = params;
    
    id block = ^(id obj, BOOL *ignored) {
        NSDictionary *dic = obj;
        
        NSArray *wordArray = [dic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                NSString *score = [wDic objectForKey:@"sc"];
                [tempStr appendString: str];
                [tempStr appendFormat:@" 置信度:%@",score];
                [tempStr appendString: @"\n"];
            }
        }
        
    };
    
    id eh = ^(NSError *err) {
        NSLog(@"json parser error");
        //        self.output.string = err.description;
    };
    
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    [parser parse:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return tempStr;
}
@end
