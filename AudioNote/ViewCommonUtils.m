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
#define api_device_url @"http://xiao6yuji.com/api/device"
#define api_device_data_url @"http://xiao6yuji.com/api/device/data"
#define RMB_WAN 10000
#define TIME_HOUR 60

// voice record list with format
- (NSMutableArray*) getDataListWith: (DatabaseUtils*) databaseUtils Limit: (NSInteger) limit Offset: (NSInteger) offset {
    NSMutableArray *latestDataList = [NSMutableArray arrayWithCapacity:0];
    
    
    NSMutableArray *dataArray = [databaseUtils selectLimit: limit Offset: offset Order: @"id" Format: @""];
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
        [mutableDictionary setObject:[dict objectForKey:@"id"]   forKey:@"id"];
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

+ (NSString *) httpGet: (NSString *) path {
    NSString *str         = [api_device_url stringByAppendingFormat:@"?%@", path];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"URL: %@", str);
    NSURL *url            = [NSURL URLWithString:str];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response    = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return response;

}

+ (NSString *) httpPost: (NSURL *) url Data: (NSString *) _data {
    _data = [_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST URL Data: %@", _data);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [_data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    NSLog(@"POST Response: %@", response);
    return response;
}

+ (NSString *) httpPostDevice: (NSString *) _data {
    NSURL *url = [NSURL URLWithString:api_device_url];
    return [ViewCommonUtils httpPost: url Data:_data];
}

+ (NSString *) httpPostDeviceData: (NSString *) _data {
    NSURL *url = [NSURL URLWithString:api_device_data_url];
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *_uid = [userDefaultes stringForKey:@"uid"];
    if([_uid length] <= 0)
        _uid = [ViewCommonUtils generateUID];
    
    _data = [_data stringByAppendingFormat:@"&uid=%@", _uid];
    NSLog(@"data: %@", _data);
    return [ViewCommonUtils httpPost: url Data:_data];
}

// 100000 元 => 10 万元
- (NSDictionary *) dealWithMoney: (NSString *) nMoney {
    NSString *unit = @"元";
    NSInteger iMoney = [nMoney intValue];
    
    if (iMoney > RMB_WAN) {
        nMoney = [NSString stringWithFormat:@"%.1f", roundf(iMoney * 10 / RMB_WAN ) / 10];
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

+ (BOOL) isNetworkAvailable {
    
    BOOL isExistenceNetwork = NO;
    NSString *netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            netWorkType = @"3g";
            break;
    }
    
    return isExistenceNetwork;
}
+ (NSString *) networkType {
    
    BOOL isExistenceNetwork = NO;
    NSString *_netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            _netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            _netWorkType = @"3g";
            break;
    }
    
    return _netWorkType;
}

+ (NSString*)devicePlatform {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE:  Machine hardware platform: %@", deviceString);
    return deviceString;
}

+ (NSString *) generateUID {
    // name/os/id/osVersion are necessary.
    NSString *device  = [NSString stringWithFormat:@"device={\"name\":\"%@\"", [[UIDevice currentDevice] name]];
    device = [device stringByAppendingFormat:@",\"model\":\"%@\"", [[UIDevice currentDevice] model]];
    device = [device stringByAppendingFormat:@",\"localizedModel\":\"%@\"", [[UIDevice currentDevice] localizedModel]];
    device = [device stringByAppendingFormat:@",\"os\":\"%@\"", [[UIDevice currentDevice] systemName]];
    device = [device stringByAppendingFormat:@",\"id\":\"%@\"", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    device = [device stringByAppendingFormat:@",\"osVersion\":\"%@\"", [[UIDevice currentDevice] systemVersion]];
    device = [device stringByAppendingFormat:@",\"IFlyVersion\":\"%@\"", [IFlySetting getVersion]];
    device = [device stringByAppendingFormat:@",\"platform\":\"%@\"", [ViewCommonUtils devicePlatform]];
    device = [device stringByAppendingString:@"}"];
    NSString * response = [ViewCommonUtils httpPostDevice: device];
    
    NSMutableDictionary *mutableDictionary2 = [[NSMutableDictionary alloc] init];

    // JSON NSString convert to NSMutableDictionary
    
    NSError *error;
    mutableDictionary2 = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    //NSString *idstr = [mutableDictionary2 objectForKey:@"id"];
    NSString *_code = [mutableDictionary2 objectForKey:@"code"];
    NSString *_uid  = [mutableDictionary2 objectForKey:@"info"];
    NSLog(@"code: %@, uid: %@", _code, _uid);

    
    // 将上述数据全部存储到 NSUserDefaults 中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_uid forKey:@"uid"];
    // 这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
    return _uid;
}
@end