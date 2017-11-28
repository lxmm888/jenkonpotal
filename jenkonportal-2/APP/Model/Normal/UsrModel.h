//
//  UsrModel.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsrModel : NSObject<NSCoding>

@property (copy, nonatomic) NSString *usrname;//用户id
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *siteId; //add by zl 20170816 所属平台Id
@property (copy, nonatomic) NSString *portraitUri;

/**
 status: 与好友的关系。下面是好友关系的对照表，上面数据得到的status 值是20，表示和这个用户已经是好友了。
	| 对自己的状态    |自己  | 好友 | 对好友的状态
	| 发出了好友邀请  | 10   | 11  | 收到了好友邀请
	| 发出了好友邀请  | 10   | 21  | 忽略了好友邀请
	| 已是好友       | 20   | 20  | 已是好友
	| 已是好友       | 20   | 30  | 删除了好友关系
	| 删除了好友关系  | 30   | 30  | 删除了好友关系
 */
@property(nonatomic, strong) NSString *status;

@property(nonatomic, strong) NSString *updatedAt;

@property(nonatomic, strong) NSString *displayName;

// 融云的token
@property (copy, nonatomic) NSString *token;

@end
