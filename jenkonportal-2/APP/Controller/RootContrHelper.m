//
//  RootContrHelper.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "RootContrHelper.h"
#import "APPTabBarContr.h"
#import "LoginContr.h"
#import "AppSession.h"
#import <RongIMKit/RongIMKit.h>

@implementation RootContrHelper

+ (UIViewController *)rootContr
{
    UIViewController *root = nil;
    // 在LoginContr，成功登录后下次自动登录；除非登出，都不再显示LoginContr
    UsrModel *usr = [[AppSession shareSession] loadUsrFromDB];
    
    if (usr) {
        root = [[APPTabBarContr alloc] init];
        [AppSession shareSession].didTabBarContrLaunched = YES;
        
        // [融云]设置当前用户
        [RCIM sharedRCIM].currentUserInfo = [[RCUserInfo alloc] initWithUserId:usr.usrname name:usr.nickname portrait:usr.portraitUri];
        
        // [融云]融云长连接
        [[RCIM sharedRCIM] connectWithToken:usr.token success:^(NSString *userId) {
            
        } error:^(RCConnectErrorCode status) {
            XILog(@"%@", [NSString stringWithFormat:@"错误代码%ld", status]);
        } tokenIncorrect:^{
            XILog(@"token非法");
        }];

    }else {
        root = [[LoginContr alloc] init];
    }
    
    return root;
}

@end
