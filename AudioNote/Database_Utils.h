//
//  Database_Utils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_Database_Utils_h
#define AudioNote_Database_Utils_h

#import <sqlite3.h>
#define kDatabaseName @"voice_record.sqlite3"

NSMutableArray* selectDBwithDate(){//char *beginDate, char *endDate) {
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
    NSLog(@"database path: %@",databaseFilePath);
    int result = sqlite3_open([databaseFilePath UTF8String], &database);
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
            // set key: value
            [mutableDictionary setObject:[NSNumber numberWithInteger:_id]  forKey:@"id"];
            [mutableDictionary setObject:_input forKey:@"input"];
            [mutableDictionary setObject:_description forKey:@"description"];
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

// View Function

// init self.initDataList
// call it when voice record # onResult
NSMutableArray* initDataListWithDB() {
    NSMutableArray *latestDataList = [NSMutableArray arrayWithCapacity:0];//[[NSMutableArray alloc] initWithObjects:@"first",@"two",@"three",nil];
    
    
    NSMutableArray *dataArray = selectDBwithDate();
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

#endif
