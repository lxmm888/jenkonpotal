//
//  AppFontMgr.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/12.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "AppFontMgr.h"
#import "XICommonDef.h"

static CGFloat _standardFontSize;

@implementation AppFontMgr

+ (void)load
{
    [super load];
    
    if (IS_5_5_INCH_SCREEN) {
        _standardFontSize = 16;
    }else if (IS_4_7_INCH_SCREEN){
        _standardFontSize = 14;
    }else {
        _standardFontSize = 13;
    }
}

+ (CGFloat)standardFontSize
{
    return _standardFontSize;
}

@end
