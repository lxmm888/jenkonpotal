//
//  AppSession.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>
#import "UsrModel.h"

@interface AppSession : NSObject

+ (instancetype)shareSession;
// 当前用户
@property (strong, nonatomic) UsrModel *usr;
// tabBarContr已经完成初始化，用于在LoginContr -back中作条件判断
@property (assign, nonatomic) BOOL didTabBarContrLaunched;

// 本地化用户数据
- (void)updateUsrToDB;
// 加载本地用户数据
- (UsrModel *)loadUsrFromDB;

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;
+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo;
+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo;
+ (NSString *)getIconCachePath:(NSString *)fileName;

+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

@end
