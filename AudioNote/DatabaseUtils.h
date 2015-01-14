//
//  Database_Utils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_Database_Utils_h
#define AudioNote_Database_Utils_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kDatabaseName @"voice_record.sqlite3"
#define myLog NSLog

@interface DatabaseUtils : NSObject

@property NSString *databaseFilePath;

+ (void) setUP;
- (NSInteger) executeSQL: (NSString *) sql;
//- (NSMutableArray*) selectFrom: (NSString*) from To: (NSString*) to;
- (NSMutableArray*) selectLimit: (NSInteger) limit Offset: (NSInteger) offset;
// 报表使用的数据来源
- (NSMutableArray*) getReportDataWithType: (NSString *) type;
- (NSString *) getReportData: (NSString *) type;
// /ProcessPattern文件中代码调用， 取得数据库中最后一笔description的分类
- (NSString*) selectTag: (NSString *) description;

@end

#endif
