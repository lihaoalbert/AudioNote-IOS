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
//#import <sqlite3.h>
#import <FMDB.h>

#define kDatabaseName @"voice_record.sqlite3"


@interface DatabaseUtils : NSObject

@property NSString *dbVersion;
@property NSString *dbName;
@property NSString *dbPath;

+ (void) setUP;
- (NSInteger) executeSQL:(NSString *) sql;
- (NSMutableArray*) selectFrom:(NSString*) from
                            To:(NSString *) to
                         Order:(NSString *) column
                        Format:(NSString *) format;
- (NSMutableArray*) selectLimit:(NSInteger) limit
                         Offset:(NSInteger) offset
                          Order:(NSString *) column
                         Format:(NSString *) format;
// 报表使用的数据来源
- (NSMutableArray*)getReportDataWithType:(NSString *) type;
- (NSString *)getReportData:(NSString *) type;
// /ProcessPattern文件中代码调用， 取得数据库中最后一笔description的分类
- (NSString*)selectTag:(NSString *)description;
- (void) deleteWithId:(NSString *)id;
- (NSMutableArray *)exportReport;
- (NSString *)dbSize;

- (void)updateSyncDataList:(NSMutableArray *)ids;
- (NSMutableArray *)unsyncDataList;
@end

#endif
