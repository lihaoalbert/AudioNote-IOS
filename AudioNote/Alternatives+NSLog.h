//
//  Alternatives+NSLog.h
//  AudioNote
//
//  Created by lijunjie on 15-1-28.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
// ALog() will display the standard NSLog but containing function and line number.
// DLog() will output like NSLog only when the DEBUG variable is set
// ULog() will show the UIAlertView only when the DEBUG variable is set


#ifndef AudioNote_Alternatives_NSLog_h
#define AudioNote_Alternatives_NSLog_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


#endif
