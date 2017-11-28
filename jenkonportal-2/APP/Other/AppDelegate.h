//
//  AppDelegate.h
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

static BOOL isProduction = FALSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCIMConnectionStatusDelegate,
                                      RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

