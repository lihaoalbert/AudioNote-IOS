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
        NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilePath=[documentsDirectory stringByAppendingPathComponent:kDatabaseName];
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
            begin datetime NOT NULL,              \
            duration integer NOT NULL DEFAULT '0',\
            create_time datetime NOT NULL,        \
            modify_time datetime NOT NULL         \
            );                                    \
        CREATE INDEX IF NOT EXISTS idx_category ON voice_record(category); \
        CREATE INDEX IF NOT EXISTS idx_create_time ON voice_record(create_time);";
    [databaseUtils executeSQL: table_voice_record];
}

- (NSInteger) executeSQL: (NSString *) sql {
    sqlite3 *database;
    
    int result = sqlite3_open([self.databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        NSLog(@"open data failed - line number: %i.", __LINE__);
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



-(NSMutableArray*) selectDBwithDate{//char *beginDate, char *endDate) {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    ////////////////////////////////
    // Open Database
    ////////////////////////////////
    NSLog(@"database path: %@",self.databaseFilePath);
    int result = sqlite3_open([self.databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        NSLog(@"Sqlite3 DataBase Open Failed.");
        NSLog(@"Abort Line Number: %i", __LINE__);
        return mutableArray;
    }
    
    ////////////////////////////////
    // Select Data into NSData
    ////////////////////////////////
    NSString *query = @"select id, input,description,category,nMoney,nTime,begin,duration,create_time,modify_time from voice_record;";
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
            NSLog(@"_id = %i\n_input = %@ \n_description = %@ \n_category = %@\n_nMoney = %i\n _nTime = %i\n _begin       = %@\n_duration = %i\n_create_time = %@\n_modify_time = %@\n===================\n", _id, _input, _description, _category, _nMoney, _nTime, _begin, _duration, _create_time, _modify_time);
            
            
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
            [mutableArray addObject: mutableDictionary];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;
}  // end of selectDBwithDate()


-(NSMutableArray*) reportWithType: (NSString *) type {
    sqlite3 *database;
    NSString *databaseFilePath;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    ////////////////////////////////
    // Open Database
    ////////////////////////////////
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    databaseFilePath=[documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    int result = sqlite3_open([databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK) {
        return mutableArray;
    }
    
    ////////////////////////////////
    // Select Data into NSData
    ////////////////////////////////
    NSString *query = @"select category sum(nMoney) as nMoney, sum(nTime) as nTime from voice_record group by category;";
    float _nMoney, _nTime;
    NSString *_category;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _nMoney      = (float)sqlite3_column_double(statement, 4);
            _nTime       = sqlite3_column_int(statement, 5);
            _category    = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 3)encoding:NSUTF8StringEncoding];
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDictionary setObject:_category forKey:@"category"];
            [mutableDictionary setObject:[NSNumber numberWithFloat:_nMoney]  forKey:@"nMoney"];
            [mutableDictionary setObject:[NSNumber numberWithFloat:_nTime]  forKey:@"nTime"];
            [mutableArray addObject: mutableDictionary];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    return mutableArray;
}  // end of reportWithType()

@end

