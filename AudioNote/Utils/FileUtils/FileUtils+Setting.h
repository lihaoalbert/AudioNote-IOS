//
//  FileUtils+Setting.h
//  iLearn
//
//  Created by lijunjie on 15/8/22.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "FileUtils.h"
@class User;

@interface FileUtils (Setting)

+ (NSArray *)appFiles;
+ (void)removeUser:(User *)user;
@end
