//
//  FileUtils+Setting.m
//  iLearn
//
//  Created by lijunjie on 15/8/22.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "FileUtils+Setting.h"
#import "User.h"

@implementation FileUtils (Setting)


+ (NSArray *)appFiles {
    NSString *basePath = [FileUtils basePath];
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSString *filePath, *configDir, *configPath;
    NSDictionary *dict = [NSDictionary dictionary];
    BOOL isDir = NO;
    for(NSString *fileName in files) {
        filePath   = [basePath stringByAppendingPathComponent:fileName];
        configDir  = [filePath stringByAppendingPathComponent:CONFIG_DIRNAME];
        configPath = [configDir stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
        if([fileManager fileExistsAtPath:configPath isDirectory:&isDir]) {
            dict = [FileUtils readConfigFile:configPath];
            User *user = [[User alloc] initWithConfigPath:configPath];
            NSNumber *dirSize = [self dirFileSize:filePath];
            
            [array addObject:@[user, dirSize]];
        }
    }
    return [NSArray arrayWithArray:array];
}

+ (void)removeUser:(User *)user {
    User *currentUser = [[User alloc] init];
    
    if([currentUser.employeeID isEqualToString:user.employeeID]) {
        NSString *basePath = [currentUser basePath];
        NSString *cachePath = [basePath stringByAppendingPathComponent:CACHE_DIRNAME];
        [FileUtils removeFile:cachePath];
        NSString *downloadPath = [basePath stringByAppendingPathComponent:DOWNLOAD_DIRNAME];
        [FileUtils removeFile:downloadPath];
    }
    else {
        [FileUtils removeFile:[user basePath]];
    }
    
}
@end
