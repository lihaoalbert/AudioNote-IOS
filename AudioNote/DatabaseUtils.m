//
//  Database_Utils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DatabaseUtils.h"

@implementation DatabaseUtils

#define myNSLog

- (id) init {
    if (self = [super init]) {
        NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilePath        = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
        //NSLog(@"%@", self.databaseFilePath);
    }
    return self;
}

// basic table setup
+ (void) setUP {
    DatabaseUtils *databaseUtils = [[DatabaseUtils alloc] init];
    NSString *table_voice_record = @"CREATE TABLE IF NOT EXISTS voice_record ( \
            id integer PRIMARY KEY AUTOINCREMENT, \
            input varchar(1000) NOT NULL,         \
            description varchar(1000) NOT NULL,   \
            category varchar(100) NOT NULL,       \
            nMoney Integer NOT NULL DEFAULT '0',  \
            nTime Integer NOT NULL DEFAULT '0',   \
            nDate varchar(50) NOT NULL DEFAULT '', \
            begin datetime NOT NULL,              \
            duration integer NOT NULL DEFAULT '0',\
            create_time datetime NOT NULL,        \
            modify_time datetime NOT NULL         \
            );                                    \
        CREATE INDEX IF NOT EXISTS idx_category ON voice_record(category); \
        CREATE INDEX IF NOT EXISTS idx_create_time ON voice_record(create_time);";
        // input       - 语音转义文句
        // description - 文句解析保留字
        // category    - 分类
        // nMoney      - 金额 （整型）
        // nTime       - 时间 （整型)
        // nDate       - 日期  (2015-01-15)
        // begin       - 开始录音时间
        // duration    - 录音持续时间
        //
    [databaseUtils executeSQL: table_voice_record];
}

- (NSInteger) executeSQL: (NSString *) sql {
    sqlite3 *database;
    //NSLog(@"executeSQL: %@", sql);
    int result = sqlite3_open([self.databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        NSLog(@"open database failed - line number: %i.", __LINE__);
        return -__LINE__;
    }
 
    char *errorMsg;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"execute sql failed.");
        NSLog(@"%@", sql);
        NSLog(@"errorMsg.");
        NSLog(@"%s", errorMsg);
        return -__LINE__;
    }

    ////////////////////////////////
    // Get the ID just execute
    ////////////////////////////////
    NSInteger lastRowId = sqlite3_last_insert_rowid(database);
    if (lastRowId > 0)
        return lastRowId;
    else
        NSLog(@"lastRowId#%li < 0.", lastRowId);
    
    return -__LINE__;
} // end of executeSQL()

- (void) deleteWithId: (NSString *) id {
    NSString *sql = [NSString stringWithFormat:@"delete from voice_record where id = %@", id];
    [self executeSQL: sql];
}


- (NSMutableArray*) selectFrom: (NSString*) from
                            To: (NSString *) to
                         Order: (NSString *) column
                        Format: (NSString *) format {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    if (sqlite3_open([self.databaseFilePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return mutableArray;
    }
    
    //create_time >= '%s 00:00:00' AND create_time <= '%s 23:59:59'
    if(from.length == 10)
        from = [NSString stringWithFormat:@"%@ 00:00:00", from];
    if(to.length == 10)
        to = [NSString stringWithFormat:@"%@ 23:59:59", to];
    
    ////////////////////////////////
    // Select Data into NSData
    ////////////////////////////////
    NSString *query = @"select id, input,description,category,nMoney,nTime,begin,duration,create_time,modify_time";
    query = [query stringByAppendingString:@" from voice_record where "];
    query = [query stringByAppendingFormat:@" create_time >= '%@' and create_time <= '%@' ", from , to];
    NSLog(@"executeSQL: %@", query);
    int _id, _nMoney, _nTime, _duration;
    NSString *_input, *_description, *_category;
    NSString *_begin, *_create_time, *_modify_time;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _id          = sqlite3_column_int(statement, 0);
            _input       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1)encoding:NSUTF8StringEncoding];
            _description = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2)encoding:NSUTF8StringEncoding];
            _category    = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3)encoding:NSUTF8StringEncoding];
            _nMoney      = sqlite3_column_int(statement, 4);
            _nTime       = sqlite3_column_int(statement, 5);
            _begin       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6)encoding:NSUTF8StringEncoding];
            _duration    = sqlite3_column_int(statement, 7);
            _create_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 8)encoding:NSUTF8StringEncoding];
            _modify_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 9)encoding:NSUTF8StringEncoding];
            //NSLog(@"_id = %i\n_input = %@ \n_description = %@ \n_category = %@\n_nMoney = %i\n _nTime = %i\n _begin       = %@\n_duration = %i\n_create_time = %@\n_modify_time = %@\n===================\n", _id, _input, _description, _category, _nMoney, _nTime, _begin, _duration, _create_time, _modify_time);
            
            
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_id]  forKey:@"id"];
            [mutableDictionary setObject:_input forKey:@"input"];
            [mutableDictionary setObject:_description forKey:@"description"];
            [mutableDictionary setObject:_category forKey:@"category"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_nMoney]  forKey:@"nMoney"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_nTime]  forKey:@"nTime"];
            [mutableDictionary setObject:_begin forKey:@"begin"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_duration]  forKey:@"duration"];
            [mutableDictionary setObject:_create_time forKey:@"create_time"];
            [mutableDictionary setObject:_modify_time forKey:@"modify_time"];
            
            
            if([format isEqualToString: @"json"]) {
                ////////////////////////////
                // Transform mutableDictionary to json NSString
                ////////////////////////////
                NSError *error;
                NSData *jsonData;
                NSString *jsonStr;
                
                if ([NSJSONSerialization isValidJSONObject:mutableDictionary]) {
                    // NSMutableDictionary convert to JSON Data
                    jsonData = [NSJSONSerialization dataWithJSONObject:mutableDictionary options:NSJSONWritingPrettyPrinted error:&error];
                    // JSON Data convert to NSString
                    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    //NSLog(@"NSMutableDictionary to JSON String: %@", jsonStr);
                }
                
                // put josnString to NSMutableArray
                [mutableArray addObject:jsonStr];
            } else {
                [mutableArray addObject: mutableDictionary];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;
}  // end of selectFrom: To: Order: Format:()


- (NSMutableArray*) selectLimit: (NSInteger) limit
                         Offset: (NSInteger) offset
                          Order: (NSString *) column
                         Format: (NSString *) format{
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    if (sqlite3_open([self.databaseFilePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return mutableArray;
    }
    
    ////////////////////////////////
    // Select Data into NSMutableDictionary
    ////////////////////////////////
    NSString *query = [NSString stringWithFormat:@"select id, input,description,category,nMoney,nTime,begin,duration,create_time,modify_time, nDate from voice_record order by %@ asc ", column];
    query = [query stringByAppendingFormat:@" limit %lu offset %lu", limit, offset];
    int _id, _nMoney, _nTime, _duration;
    NSString *_input, *_description, *_category, *_nDate;
    NSString *_begin, *_create_time, *_modify_time, *_simple_create_time;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _id          = sqlite3_column_int(statement, 0);
            _input       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1)encoding:NSUTF8StringEncoding];
            _description = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 2)encoding:NSUTF8StringEncoding];
            _category    = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3)encoding:NSUTF8StringEncoding];
            _nMoney      = sqlite3_column_int(statement, 4);
            _nTime       = sqlite3_column_int(statement, 5);
            _begin       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 6)encoding:NSUTF8StringEncoding];
            _duration    = sqlite3_column_int(statement, 7);
            _create_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 8)encoding:NSUTF8StringEncoding];
            _modify_time = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 9)encoding:NSUTF8StringEncoding];
            _nDate       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 10)encoding:NSUTF8StringEncoding];
            if ([_modify_time length] == 19)
                _simple_create_time = [_create_time substringWithRange:NSMakeRange(0, 10)];
            else
                _simple_create_time = _create_time;
            //NSLog(@"_id = %i\n_input = %@ \n_description = %@ \n_category = %@\n_nMoney = %i\n _nTime = %i\n _begin       = %@\n_duration = %i\n_create_time = %@\n_modify_time = %@\n===================\n", _id, _input, _description, _category, _nMoney, _nTime, _begin, _duration, _create_time, _modify_time);
            
            
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_id]  forKey:@"id"];
            [mutableDictionary setObject:_input forKey:@"input"];
            [mutableDictionary setObject:_description forKey:@"description"];
            [mutableDictionary setObject:_category forKey:@"category"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_nMoney]  forKey:@"nMoney"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_nTime]  forKey:@"nTime"];
            [mutableDictionary setObject:_nDate forKey:@"nDate"];
            [mutableDictionary setObject:_begin forKey:@"begin"];
            [mutableDictionary setObject:[NSNumber numberWithInteger:_duration]  forKey:@"duration"];
            [mutableDictionary setObject:_create_time forKey:@"create_time"];
            [mutableDictionary setObject:_modify_time forKey:@"modify_time"];
            [mutableDictionary setObject:_simple_create_time forKey:@"simple_create_time"];
            
            
            if([format isEqualToString: @"json"]) {
                ////////////////////////////
                // Transform mutableDictionary to json NSString
                ////////////////////////////
                NSError *error;
                NSData *jsonData;
                NSString *jsonStr;
                
                if ([NSJSONSerialization isValidJSONObject:mutableDictionary]) {
                    // NSMutableDictionary convert to JSON Data
                    jsonData = [NSJSONSerialization dataWithJSONObject:mutableDictionary options:NSJSONWritingPrettyPrinted error:&error];
                    // JSON Data convert to NSString
                    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    //NSLog(@"NSMutableDictionary to JSON String: %@", jsonStr);
                }
                
                // put josnString to NSMutableArray
                [mutableArray addObject:jsonStr];
            } else {
                [mutableArray addObject: mutableDictionary];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;
}  // end of selectDBwithDate()


- (NSString*) selectTag: (NSString *) description {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSString *category = @"-1";
    
    if (sqlite3_open([self.databaseFilePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return category;
    }
    
    ////////////////////////////////
    // Select Data into NSMutableDictionary
    ////////////////////////////////
    NSString *query = @"select category from voice_record where description = ";
    query = [query stringByAppendingFormat:@"'%@' order by id desc ", description];
    NSLog(@"%@", query);
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            category       = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0)encoding:NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return category;
}  // end of selectTag()



- (NSMutableArray *) getReportData: (NSString *) type {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSString *data = [[NSString alloc] init];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    if (sqlite3_open([self.databaseFilePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return mutableArray;
    }
    
    NSString *where = [[NSString alloc] init];
    NSDate *today   = [NSDate date];
    ////////////////////////////////
    // Select Data into NSData
    ////////////////////////////////
    if ([type isEqual: @"today"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todayStr = [dateFormatter stringFromDate:today];
        
        where = [where stringByAppendingString:@" strftime('%Y-%m-%d',create_time) = "];
        where = [where stringByAppendingFormat:@" '%@'",todayStr];
    // [TODO] 分拆出来成为独立的function lastest_n_days
        
    } else if ([type isEqual: @"latest_7_days"]) {
        /*NSCalendar *calendar    = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekOfYear fromDate:today];
        NSInteger week          = [comps weekOfYear];
        
        where = [where stringByAppendingString:@" cast(strftime('%W',create_time) as int) = "];
        where = [where stringByAppendingFormat:@" %li",(long)week];
         */
        where = [where stringByAppendingString:@"cast(strftime('%Y%m%d', datetime()) as int) - cast(strftime('%Y%m%d', create_time) as int) <= 7"];
    } else if ([type isEqual: @"this_month"]) {
        where = @" create_time between datetime('now','start of month','+1 second') and datetime('now','start of month','+1 month','-1 second')";
        
    } else if ([type isEqual: @"this_year"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *yearStr = [dateFormatter stringFromDate:today];
        
        where = [where stringByAppendingString:@" strftime('%Y',create_time) = "];
        where = [where stringByAppendingFormat:@" '%@'",yearStr];
    } else {
        where = @" 2 = 2";
    }
    //NSLog(@"%@", where);
    
    NSString *query = @"select sum(nMoney) as nMoney, sum(nTime) as nTime from voice_record where ";
    query = [query stringByAppendingString:where];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0"];
    NSString *formatMoney;
    
    int _nMoney, _nTime;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _nMoney   = sqlite3_column_int(statement, 0);
            _nTime    = sqlite3_column_int(statement, 1);
            //NSLog(@"_type = %@\n_nMoney = %i\n _nTime = %i\n===================\n", type, _nMoney, _nTime);

            
            formatMoney = [numberFormatter stringFromNumber:[NSNumber numberWithInt: _nMoney]];
            
            data = [data stringByAppendingFormat:@"%@ 元 / ", formatMoney];
            data = [data stringByAppendingFormat:@"%i 分钟", _nTime];
            [mutableArray addObject: data];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;

}

-(NSMutableArray*) getReportDataWithType: (NSString *) type {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    if (sqlite3_open([self.databaseFilePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return mutableArray;
    }
    
    ////////////////////////////////
    // Select Data into NSData
    ////////////////////////////////
    NSString *query = @"select category, sum(nMoney) as nMoney, sum(nTime) as nTime, count(1) as nCount from voice_record group by category;";
    int _nMoney, _nTime, _nCount;
    NSString *_category;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0"];
    NSString *formatMoney;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _category = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0)encoding:NSUTF8StringEncoding];
            _nMoney   = sqlite3_column_int(statement, 1);
            _nTime    = sqlite3_column_int(statement, 2);
            _nCount   = sqlite3_column_int(statement, 3);

            
            formatMoney = [numberFormatter stringFromNumber:[NSNumber numberWithInt: _nMoney]];
            
            NSString *str = _category;
            if(_category.length == 0) {
                str = @"日志";
                str = [str stringByAppendingFormat:@": %i 笔", _nCount];
            } else {
                str = [str stringByAppendingFormat:@": %@ 元 / ", formatMoney];
                str = [str stringByAppendingFormat:@"%i 分钟", _nTime];
            }
            [mutableArray addObject: str];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;
}  // end of reportWithType()

@end

