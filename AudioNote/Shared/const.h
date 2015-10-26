//
//  const.h
//  AudioNote
//
//  Created by lijunjie on 15/9/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_const_h
#define AudioNote_const_h

#define BASE_URL     @"http://xiao6say.com"
#define BASE_PATH    @"api"

#define PGYER_SHORTCUT   @"xiao6say"
#define PGYER_APP_KEY    @"45be6d228e747137bd192c4c47d4f64a"
#define PGYER_APP_ID     @"9059b07bfaefaa18ab594c70f73def0f"
#define PYGER_PUBLIC_URL @"http://www.pgyer.com/xiao6say"
#define PGYER_INFO_URL   @"http://www.pgyer.com/apiv1/app/getAppKeyByShortcut"


#define DATE_FORMAT     @"yyyy/MM/dd HH:mm:ss" // 用户验证时，用到时间字符串时的存储格式

#define DB_DIRNAME       @"db"
#define DB_FILENAME      @"xiao6say.db"

#define CACHE_DIRNAME    @"cache"
#define CONFIG_DIRNAME    @"config"

#define PUSH_DATA_TO_SERVER_INTERVAL 60*10

#define DEVICE_CONFIG_FILENAME @"device.json"
#define WEIXINER_CONFIG_FILENAME @"weixiner.json"
#define WEIXIN_BIND_DEVICE_FILENAME @"weixin_bind_device.json"
#define WEIXIN_UNBIND_DEVICE_FILENAME @"weixin_unbind_device.json"
#define SETTINGS_CONFIG_FILENAME @"settings.json"
#define GESTURE_PASSWORD_CONFIG_FILENAME @"gesture_password.json"

typedef NS_ENUM(NSInteger, SettingsIndex) {
    SettingsWeixin = 0,
    SettingsAppInfo = 1,
    SettingsExport = 2,
    SettingsUpgrade = 3
};
#endif
