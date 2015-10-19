//
//  const.h
//  AudioNote
//
//  Created by lijunjie on 15/9/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_const_h
#define AudioNote_const_h

#define BASE_URL     @"http://xiao6yuji.com"

#define PGYER_SHORTCUT   @"xiao6say"
#define PGYER_APP_KEY    @"45be6d228e747137bd192c4c47d4f64a"
#define PGYER_APP_ID     @"9059b07bfaefaa18ab594c70f73def0f"
#define PYGER_PUBLIC_URL @"http://www.pgyer.com/xiao6say"
#define PGYER_INFO_URL   @"http://www.pgyer.com/apiv1/app/getAppKeyByShortcut"

#define DB_DIRNAME       @"db"
#define DB_FILENAME      @"xiao6say.db"

typedef NS_ENUM(NSInteger, SettingsIndex) {
    SettingsAppInfo = 0,
    SettingsFileInfo = 1,
    SettingsExport = 2,
    SettingsUpgrade = 3
};
#endif
