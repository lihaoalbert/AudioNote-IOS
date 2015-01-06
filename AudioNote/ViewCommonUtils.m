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


// voice record list with format
-(NSMutableArray*) getDataListWithDB: (DatabaseUtils*) databaseUtils {
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
            NSLog(@"%10@: %@", key, dict[key]);
        }
    }
    return latestDataList;
}

@end