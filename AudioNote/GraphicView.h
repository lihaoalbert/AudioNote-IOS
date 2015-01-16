//
//  GraphicView.h
//  DrawGraphic
//
//  Created by wu on 14-11-12.
//  Copyright (c) 2014年 Phantom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#define MAX_INPUT_LEN       1000
#define SUCCESS             0
#define ERROR               -1
#define kDatabaseName       @"voice_record.sqlite3"
#define debug_printf        printf

@interface GraphicView : UIView {
    CGPoint m_startPointMoney;
    CGPoint m_startPointTime;
    int m_nWidth;
    int m_nHeight;
    int m_timeTotal;
    int m_moneyTotal;
    int m_timePieIndex;
    int m_moneyPieIndex;
    NSMutableArray *m_colorArray;
    NSMutableArray *m_moneyArray;
    NSMutableArray *m_timeArray;
    NSMutableArray *m_moneyArraySorted;
    NSMutableArray *m_timeArraySorted;
    NSString *m_nszBeginDate,*m_nszEndDate;
}

- (void) setStartPointMoney: (CGPoint) p;
- (void) setStartPointTime: (CGPoint) p;
- (void) setWidth: (int) width;
- (void) setHeight: (int) height;
- (void) setBeginDate: (NSString*) datestr;
- (void) setEndDate: (NSString*) datestr;
- (void) setColorArray: (NSMutableArray *) arrColor;
- (int) loadFromDB;

@end

@interface MY_KEY_VALUE : NSObject
@property NSString * myKey;
@property int myValue;
@end