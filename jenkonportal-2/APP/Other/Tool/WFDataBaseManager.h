//
//  WFDataBaseManager.h
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/21.
//  Copyright © 2017年 com.xia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import "UsrModel.h"
#import "WFGroupInfo.h"
@class WFYAnnouncementModel;
@class WFYCollectionModel;

@interface WFDataBaseManager : NSObject

+ (WFDataBaseManager *)shareInstance;


#pragma mark 用户

//存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user;

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId;

#pragma mark 好友

//从表中获取所有好友信息 //RCUserInfo
- (NSArray *)getAllFriends;

//从表中获取某个好友的信息
- (UsrModel *)getFriendInfo:(NSString *)friendId;

#pragma mark  群

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB;

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId;

//存储群组信息
- (void)insertGroupToDB:(RCGroup *)group;

- (void)insertGroupsToDB:(NSMutableArray *)groupList  complete:(void (^)(BOOL))result;

//从表中获取群组信息
- (WFGroupInfo *)getGroupByGroupId:(NSString *)groupId;

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup;

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result;

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId;

#pragma mark  发布公告
//存储公告
- (void)insertAnnouncementToDB:(WFYAnnouncementModel *)announcement;

- (void)insertAnnouncementToDB:(NSMutableArray *)announcementList  complete:(void (^)(BOOL))result;

//删除公告
- (void)deleteAnnouncementToDB:(NSString *)announcementId;

//从表中获取全部公告
- (NSArray *)getAllAnnouncement;

//从表中获取通知信息
- (WFYAnnouncementModel *)getAnnouncementByID:(NSString *)announcementId;

#pragma mark 收藏
//收藏
//删除表中的收藏信息
//清空表中的所有的群组信息
- (BOOL)clearCollectionfromDB;

- (void)insertCollectionToDB:(WFYCollectionModel *)collection;

- (void)insertCollectionsToDB:(NSMutableArray *)collectionList complete:(void (^)(BOOL))result;
//获取全部收藏
- (NSMutableArray *)getAllCollection;
//从表中获取收藏信息
- (WFYCollectionModel *)getCollectionByCollectionId:(NSString *)CollectionId;

#pragma mark  工作台门户
//从表中获取首页的门户内容
- (NSMutableArray *)getHomePortalItem;

//存储首页的门户内容
- (void)insertHomePortalItemToDB:(NSMutableArray *)portalItemList
                        complete:(void (^)(BOOL))result;
@end
