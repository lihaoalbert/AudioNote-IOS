//
//  NSMutableArray+Util.m
//  ForJunJie
//
//  Created by qianfeng on 15-1-10.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "NSMutableArray+Util.h"

@implementation NSMutableArray (Util)

@end

@implementation NSMutableArray (Move)

- (void)moveLeft
{
    [self addObject:@""];
    [self exchangeObjectAtIndex:0 withObjectAtIndex:self.count-1];
    [self removeObjectAtIndex:0];
}

- (void)moveRight
{
    [self insertObject:@"" atIndex:0];
    [self exchangeObjectAtIndex:0 withObjectAtIndex:self.count-1];
    [self removeLastObject];
}

- (void)moveLeftStep:(NSInteger)step
{
    for (NSInteger i = 0; i < step; i++) {
        [self moveLeft];
    }
}

- (void)moveRightStep:(NSInteger)step
{
    for (NSInteger i = 0; i < step; i++) {
        [self moveRight];
    }
}

@end
