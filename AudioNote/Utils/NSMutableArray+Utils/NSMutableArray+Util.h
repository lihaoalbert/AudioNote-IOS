//
//  NSMutableArray+Util.h
//  ForJunJie
//
//  Created by qianfeng on 15-1-10.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Util)

@end

@interface NSMutableArray (Move)

typedef NS_ENUM(NSUInteger, MoveDirection) {
    kMoveDirectionNone = 0,
    kMoveDirectionLeft = 1,
    kMoveDirectionRight = 2
};

@property (nonatomic) MoveDirection direction;

- (void)moveLeft;
- (void)moveRight;
- (void)moveLeftStep:(NSInteger)step;
- (void)moveRightStep:(NSInteger)step;

@end