//
//  XICommonDef.h
//  jenkon
//
//  Created by 冯文林  on 17/5/3.
//  Copyright © 2017年 com.huiyang. All rights reserved.
//

#ifndef XICommonDef_h
#define XICommonDef_h

#ifdef DEBUG
// - debug打印
#define XILog(fmt, ...) NSLog((@"** %@(line:%d) ** %s " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, ##__VA_ARGS__)

#else

#define XILog(...)

#endif

// - 常量
#define kStatusBarH 20
#define kNaviBarH 44
#define kTabBarH 49

#define kToolBarH 44

// - 屏幕尺寸
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IS_3_5_INCH_SCREEN (SCREEN_WIDTH == 320.0 && SCREEN_HEIGHT == 480.0) ? 1 : 0
#define IS_4_INCH_SCREEN (SCREEN_WIDTH == 320.0 && SCREEN_HEIGHT == 568.0) ? 1 : 0
#define IS_4_7_INCH_SCREEN (SCREEN_WIDTH == 375.0 && SCREEN_HEIGHT == 667.0) ? 1 : 0
#define IS_5_5_INCH_SCREEN (SCREEN_WIDTH == 414.0 && SCREEN_HEIGHT == 736.0) ? 1 : 0

// - 颜色
#define rgba(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b) rgba(r, g, b, 1)

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* XICommonDef_h */
