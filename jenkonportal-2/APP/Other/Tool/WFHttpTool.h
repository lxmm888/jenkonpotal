//
//  WFHttpTool.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/7.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
#import "APPWebMgr.h"
#import "BaseApi.h"

@class WFGroupInfo;
@class WFYAnnouncementModel;
@class WFYCollectionModel;

#define WFHTTPTOOL [WFHttpTool shareInstance]


@interface WFHttpTool : NSObject

@property(nonatomic, strong) NSMutableArray *allGroups;

+ (WFHttpTool *)shareInstance;

//获取个人信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion;

//创建群组
- (void)createGroupWithGroupName:(NSString *)groupName
                 GroupMemberList:(NSArray *)groupMemberList
                        complete:(void (^)(NSString *))userId;

//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(WFGroupInfo *group))completion;

//获取我的群组
- (void)getMyGroupsWithBlock:(void (^)(NSMutableArray *result))block;

//获取群组成员列表
- (void)getGroupMembersWithGroupId:(NSString *)groupId
                             Block:(void (^)(NSMutableArray *result))block;

//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                 complete:(void (^)(BOOL))result;

//退出群组
- (void)quitGroupWithUserId:(NSString *)userID
                    GroupId:(NSString *)groupID
                   complete:(void (^)(BOOL))result;

//移除群组成员
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                   complete:(void (^)(BOOL))result;

//解散群组
- (void)dismissGroupWithUserId:(NSString *)userID
                       GroupId:(NSString *)groupID
                       complete:(void (^)(BOOL result))quitResult;

//修改群组名称
- (void)renameGroupWithGroupId:(NSString *)groupID
                    groupName:(NSString *)groupName
                     complete:(void (^)(BOOL))result;

//同步用户所属群组
- (void)syncGroupWithUserId:(NSString *)userId
                   complete:(void (^)(BOOL))result;

//医生端上传更新RegistrationID
- (void)adminUploadRegistrationID:(NSString *)registrationID
                           UserId:(NSString *)userId
                         complete:(void (^)(BOOL))result;

//根据id获取通知消息
- (void)getAnnouncementByID:(NSString *)announcementId
          successCompletion:(void (^)(WFYAnnouncementModel *model))completion;

//发送公告消息
- (void)sendAnncMsgWithUserId:(NSString *)userId
               AnnouncementId:(NSString *)announcementId
                     complete:(void (^)(BOOL))result;

//获取用户的快捷回复内容 type 1:医生与患者聊天消息;2,组织架构成员间聊天消息；3，群会话聊天消息
- (void)getQuickReplyMsgByType:(NSString *)type
             successCompletion:(void (^)(NSArray *arr))completion;

//获取办公门户
- (void)getHomePortalWithDefaultFlag:(NSString *)defaultFlag
                               Block:(void (^)(NSArray *result))block;

//收藏
- (void)doCollectWithCollection:(WFYCollectionModel *)collection
                 complete:(void (^)(NSString *))collectionId;

//根据id获取单个收藏
- (void)getCollectionByID:(NSString *)collectionId
   successCompletion:(void (^)(WFYCollectionModel *collection))completion;

//获取我的收藏
- (void)getMyCollectionsWithBlock:(void (^)(NSMutableArray *result))block;

//发送收藏转发单聊消息
- (void)sendPrivateCollectionMsgWithUserId:(NSMutableArray *)userId
               CollectionId:(NSString *)collectionId
                     complete:(void (^)(BOOL))result;

//发送收藏转发群组消息
- (void)sendGroupCollectionMsgWithUserId:(NSMutableArray *)groupId
               CollectionId:(NSString *)collectionId
                     complete:(void (^)(BOOL))result;

- (BaseApi *)WebRequestApiWithType:(WebRequestApiType)type Params:(NSDictionary *)inputParams;

@end
