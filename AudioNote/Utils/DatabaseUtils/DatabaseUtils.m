//
//  Database_Utils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DatabaseUtils.h"
#import "const.h"
#import "FileUtils.h"

@implementation DatabaseUtils

#define myNSLog

- (id) init {
    if(self = [super init]) {
        _dbPath = [FileUtils dirPath:DB_DIRNAME FileName:DB_FILENAME];
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
            is_sync boolean NOT NULL DEFAULT 0,\
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

/**
 *  需要的取值方式未定义或过于复杂时，直接执行SQL语句
 *  若是SELECT则返回搜索到的行ID
 *  若是DELECT/INSERT可忽略返回值
 *
 *  @param sql SQL语句，请参考SQLite语法
 *
 *  @return 返回搜索到数据行的ID,执行失败返回该代码行
 */
- (NSInteger)executeSQL:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        BOOL isExecuteSuccessfully = [db executeStatements:sql];
        if(!isExecuteSuccessfully) {
            NSLog(@"Executed faile with SQL below:\n%@", sql);
        }
        [db close];
    }
    else {
        NSLog(@"Cannot open DB at the path: %@", self.dbPath);
    }
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

    NSMutableArray *mutableArray = [NSMutableArray array];
    
    //create_time >= '%s 00:00:00' AND create_time <= '%s 23:59:59'
    if(from.length == 10) {
        from = [NSString stringWithFormat:@"%@ 00:00:00", from];
    }
    if(to.length == 10) {
        to = [NSString stringWithFormat:@"%@ 23:59:59", to];
    }
    
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
    
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    if (![db open]) {
        return mutableArray;
    }
    FMResultSet *s = [db executeQuery:query];
    while([s next]) {
        _id          = [s intForColumnIndex:0];
        _input       = [s stringForColumnIndex:1];
        _description = [s stringForColumnIndex:2];
        _category    = [s stringForColumnIndex:3];
        _nMoney      = [s intForColumnIndex:4];
        _nTime       = [s intForColumnIndex:5];
        _begin       = [s stringForColumnIndex:6];
        _duration    = [s intForColumnIndex:7];
        _create_time = [s stringForColumnIndex:8];
        _modify_time = [s stringForColumnIndex:9];
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
    [db close];
    return mutableArray;
}  // end of selectFrom: To: Order: Format:()


- (NSMutableArray*) selectLimit: (NSInteger) limit
                         Offset: (NSInteger) offset
                          Order: (NSString *) column
                         Format: (NSString *) format{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    if (![db open]) {
        return mutableArray;
    }
    
    ////////////////////////////////
    // Select Data into NSMutableDictionary
    ////////////////////////////////
    NSString *query = [NSString stringWithFormat:@"select id, input,description,category,nMoney,nTime,begin,duration,create_time,modify_time, nDate from voice_record order by %@ desc ", column];
    query = [query stringByAppendingFormat:@" limit %lu offset %lu", (long)limit, offset];
    int _id, _nMoney, _nTime, _duration;
    NSString *_input, *_description, *_category, *_nDate;
    NSString *_begin, *_create_time, *_modify_time, *_simple_create_time;
    
    
    FMResultSet *s = [db executeQuery:query];
    while([s next]) {
        _id          = [s intForColumnIndex:0];
        _input       = [s stringForColumnIndex:1];
        _description = [s stringForColumnIndex:2];
        _category    = [s stringForColumnIndex:3];
        _nMoney      = [s intForColumnIndex:4];
        _nTime       = [s intForColumnIndex:5];
        _begin       = [s stringForColumnIndex:6];
        _duration    = [s intForColumnIndex:7];
        _create_time = [s stringForColumnIndex:8];
        _modify_time = [s stringForColumnIndex:9];
        _nDate       = [s stringForColumnIndex:10];
        if ([_modify_time length] == 19) {
            _simple_create_time = [_create_time substringWithRange:NSMakeRange(0, 10)];
        }
        else {
            _simple_create_time = _create_time;
        }
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
    [db close];
    
    return mutableArray;
}  // end of selectDBwithDate()


- (NSString*) selectTag: (NSString *) description {
    NSString *category = @"-1";
    
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    if (![db open]) {
        return category;
    }
    
    ////////////////////////////////
    // Select Data into NSMutableDictionary
    ////////////////////////////////
    NSString *query = @"select category from voice_record where description = ";
    query = [query stringByAppendingFormat:@"'%@' order by id desc ", description];
    NSLog(@"%@", query);
    
    FMResultSet *s = [db executeQuery:query];
    while([s next]) {
        category       = [s stringForColumnIndex:0];
    }
    [db close];
    
    return category;
}  // end of selectTag()



- (NSMutableArray *)getReportData:(NSString *)type {
    NSString *data = [[NSString alloc] init];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    if (![db open]) {
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
    FMResultSet *s = [db executeQuery:query];
    while([s next]) {
        _nMoney   = [s intForColumnIndex:0];
        _nTime    = [s intForColumnIndex:1];
        //NSLog(@"_type = %@\n_nMoney = %i\n _nTime = %i\n===================\n", type, _nMoney, _nTime);

        
        formatMoney = [numberFormatter stringFromNumber:[NSNumber numberWithInt: _nMoney]];
        
        data = [NSString stringWithFormat:@"%6i元 %6i分钟", _nMoney, _nTime];
        [mutableArray addObject: data];
    }
    [db close];
    
    return mutableArray;
}

-(NSMutableArray*)getReportDataWithType: (NSString *) type {
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    if (![db open]) {
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
    //NSString *formatMoney;
    
    FMResultSet *s = [db executeQuery:query];
    while([s next]) {
        _category = [s stringForColumnIndex:0];
        _nMoney   = [s intForColumnIndex:1];
        _nTime    = [s intForColumnIndex:2];
        _nCount   = [s intForColumnIndex:3];

        //formatMoney = [numberFormatter stringFromNumber:[NSNumber numberWithInt: _nMoney]];
        
        NSString *str = _category;
        if(_category.length == 0) {
            str = @"日志";
            str = [str stringByAppendingFormat:@": %6i笔", _nCount];
        }
        else {
            str = [str stringByAppendingFormat:@": %6i元 %6i分钟", _nMoney, _nTime];
        }
        [mutableArray addObject: str];
    }
    [db close];

    return mutableArray;
}  // end of reportWithType()


@end

