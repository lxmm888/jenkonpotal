//
//  RongIMKitHelper.h
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/17.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#define WFDataSource [RongIMKitHelper shareHelper]

@interface RongIMKitHelper : NSObject<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMGroupUserInfoDataSource,RCIMGroupMemberDataSource>

+ (instancetype)shareHelper;

@end
