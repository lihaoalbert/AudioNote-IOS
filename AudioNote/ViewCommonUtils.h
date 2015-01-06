//
//  ViewCommonUtils.h
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_ViewCommonUtils_h
#define AudioNote_ViewCommonUtils_h

#import <Foundation/Foundation.h>
#import "DatabaseUtils.h"


@interface ViewCommonUtils : NSObject

-(NSMutableArray*) getDataListWithDB: (DatabaseUtils*) databaseUtils;

@end


#endif
