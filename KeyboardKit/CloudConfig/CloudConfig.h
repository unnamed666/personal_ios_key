//
//  CloudConfig.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#ifndef CloudConfig_h
#define CloudConfig_h

#define CloudProductName   [CMAppConfig getProductName]
#define CloudPackageName [CMAppConfig bundleIdentifier]

#define CloudDefaultLan    [CMAppConfig currentLanguage]
#define CloudDefaultChId   @"null"

//魔方云控的Section名称,需跟运营或测试确认一致
#define SettingManagement  @"setting_button_hidden"
#define ChangeThemeManagement  @"change_theme_hidden"
#define InfocManagement   @"infoc_report"

#endif /* CloudConfig_h */
