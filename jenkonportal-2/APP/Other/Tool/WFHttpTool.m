//
//  WFHttpTool.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/7.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFHttpTool.h"
#import "SVProgressHUD.h"
#import "WFDataBaseManager.h"
#import "AppSession.h"
#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserInfo.h>
#import "WFYUserInfo.h"
#import "SortForTime.h"
#import "AppConf.h"
#import "WFGroupInfo.h"
#import "XICommonDef.h"
#import "WFYAnnouncementModel.h"
#import "WFYHomePortalItem.h"
#import "MJExtension.h"
#import "WFDataBaseManager.h"
#import "WFYCollectionModel.h"

@implementation WFHttpTool
{
    BaseApi *_baseApi;
    APPWebMgr *_webMgr;
}

+ (WFHttpTool *)shareInstance{
    static WFHttpTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class]alloc]init];
        instance.allGroups = [NSMutableArray new];
    });
    return instance;
}

- (BaseApi *)WebRequestApiWithType:(WebRequestApiType)type Params:(NSDictionary *)inputParams{
    _webMgr = [APPWebMgr manager];
    BaseApi * baseApi=[BaseApi WebRequestApiWithType:type];
    baseApi.webDelegate = _webMgr;
    baseApi.inputParams = inputParams;
    return baseApi;
}

//根据userId获取单个用户信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion {
    RCUserInfo *userInfo =
    [[WFDataBaseManager  shareInstance] getUserByUserId:userID];
    if (!userInfo) {
        NSDictionary *inputParams =@{
                                     @"administratorName":userID,
                                     };
        _baseApi = [self WebRequestApiWithType:WebRequestApiTypeGetUserInfo Params:inputParams];
        [_baseApi connect:^(ApiRespModel *resp) {
            if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
                
                RCUserInfo *user = [RCUserInfo new];
                user.userId = userID;
                user.name = [NSString stringWithFormat:@"name%@", userID];
                user.portraitUri = [AppSession defaultUserPortrait:user];
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(user);
                    });
                }
            }else{
                NSDictionary *usrInfo = resp.resultset[@"success"][@"response"];
                RCUserInfo *user = [RCUserInfo new];
                user.userId = usrInfo[@"UserName"];
                user.name = usrInfo[@"NickName"];
                user.portraitUri = usrInfo[@"Avatar"];
                if (!user.portraitUri || user.portraitUri.length <= 0) {
                    user.portraitUri = [AppSession defaultUserPortrait:user];
                }
                [[WFDataBaseManager shareInstance] insertUserToDB:user];
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(user);
                    });
                }
            }
        } :^(NSError *error) {
            NSLog(@"getUserInfoByUserID error");
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    RCUserInfo *user = [RCUserInfo new];
                    user.userId = userID;
                    user.name = [NSString stringWithFormat:@"name%@", userID];
                    user.portraitUri = [AppSession defaultUserPortrait:user];
                    completion(user);
                });
            }
        }];
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
                    userInfo.portraitUri = [AppSession defaultUserPortrait:userInfo];
                }
                completion(userInfo);
            });
        }
    }
}

//创建群组
- (void)createGroupWithGroupName:(NSString *)groupName
                 GroupMemberList:(NSArray *)groupMemberList
                        complete:(void (^)(NSString *))userId {
    NSMutableDictionary *userIdList= [@{} mutableCopy];
    [groupMemberList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [userIdList setObject:obj forKey:[NSString stringWithFormat:@"user%u",idx+1]];
    }];
    NSDictionary *inputParams = @{
                 @"userId":kUserId,
                 @"userIdList":[AppSession dictionaryToJson:userIdList],
                 @"groupName":groupName
                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeCreatGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            userId(nil);
        }else{
            NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
            userId(resultInfo[@"ChatGroupId"]);
        }
    } :^(NSError *error) {
        userId(nil);
    }];
}

//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(WFGroupInfo *group))completion {
    NSDictionary *inputParams =@{
                                 @"groupId":groupID,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeGetGroupInfo Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            if (completion) {
                completion(nil);
            };
        }else{
            NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
            WFGroupInfo *group = [[WFGroupInfo alloc]init];
            group.groupId = [NSString stringWithFormat:@"%@",resultInfo[@"ChatGroupId"]];
            group.groupName =resultInfo[@"GroupName"];
            group.portraitUri = resultInfo[@"GroupAvatar"];
            if ([group.portraitUri isKindOfClass:[NSNull class]] || !group.portraitUri || group.portraitUri.length <= 0) {
                group.portraitUri = [AppSession defaultGroupPortrait:group];
            }
            group.creatorId = resultInfo[@"GroupCreater"];
            group.introduce = @"";
            group.number = resultInfo[@"MemberCount"];
            group.maxNumber = @"300";
            //group.creatorTime = resultInfo[@"creat_datetime"];
//            if (![resultInfo[@"DeletedAt"]
//                  isKindOfClass:[NSNull class]]) {
//                group.isDismiss = @"YES";
//            } else {
//                group.isDismiss = @"NO";
//            }
            group.isDismiss = @"NO";
            [[WFDataBaseManager shareInstance]insertGroupToDB:group];
            if ([[NSString stringWithFormat:@"%@",group.groupId] isEqualToString:groupID] && completion) {
                completion(group);
            }else if (completion) {
                completion(nil);
            }
        }
    } :^(NSError *error) {
        WFGroupInfo *group =
        [[WFDataBaseManager shareInstance] getGroupByGroupId:groupID];
        if ([group.portraitUri isKindOfClass:[NSNull class]] || !group.portraitUri || group.portraitUri.length <= 0) {
            group.portraitUri = [AppSession defaultGroupPortrait:group];
        }
        completion(group);
    }];
}

//获取当前用户所在的所有群组信息
- (void)getMyGroupsWithBlock:(void (^)(NSMutableArray *))block{
    NSMutableArray *tempArr = [[WFDataBaseManager shareInstance]getAllGroup];
    for (WFGroupInfo *group in tempArr) {
        if ([group.portraitUri isKindOfClass:[NSNull class]] || !group.portraitUri ||  group.portraitUri.length <=0) {
            group.portraitUri = [AppSession defaultGroupPortrait:group];
        }
    }
    NSDictionary *inputParams = @{@"userId":[RCIM sharedRCIM].currentUserInfo.userId};
    _baseApi=[self WebRequestApiWithType:WebRequestApiTypeMyGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
//            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
//            return;
            block(tempArr);
        } else {
            NSArray *allGroups = resp.resultset[@"success"][@"response"];
            NSMutableArray *tempArr = [NSMutableArray new];
            if ([allGroups count] >0) {
                NSMutableArray *groups = [NSMutableArray new];
                [[WFDataBaseManager shareInstance] clearGroupfromDB];
                for (NSDictionary *dic in allGroups) {
                    //![[change objectForKey:@"new"] isKindOfClass:[NSNull class]]
                    if (![dic isKindOfClass:[NSNull class]]) {
                        NSLog(@"%@",dic);
                        WFGroupInfo *group =[[WFGroupInfo alloc]init];
                        group.groupId = dic[@"ChatGroupId"];
                        group.groupName = dic[@"GroupName"];
                        group.portraitUri = dic[@"GroupAvatar"];
                        if ([group.portraitUri isKindOfClass:[NSNull class]] || !group.portraitUri || group.portraitUri.length == 0) {
                            group.portraitUri = [AppSession defaultGroupPortrait:group];
                        }
                        group.creatorId = [dic objectForKey:@"GroupCreater"];
                        if (!group.introduce) {
                            group.introduce = @"";
                        }
                        group.number =[dic objectForKey:@"MemberCount"];
                        group.maxNumber = @"500";
                        if (!group.number) {
                            group.number = @"";
                        }
                        if (!group.maxNumber) {
                            group.maxNumber = @"";
                        }
                        [tempArr addObject:group];
                        group.isJoin =YES;
                        [groups addObject:group];
                    }
                }
                [[WFDataBaseManager shareInstance] insertGroupsToDB:groups complete:^(BOOL result) {
                    if (result == YES) {
                        block(tempArr);
                    }
                }];
            }
            else{
                block(nil);
            }
        }
    } :^(NSError *error) {
        block(tempArr);
        XILog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//根据groupId获取群组成员信息
- (void)getGroupMembersWithGroupId:(NSString *)groupId
                             Block:(void (^)(NSMutableArray *))block
{
    NSDictionary *inputParams = @{@"groupId":groupId};
    _baseApi=[self WebRequestApiWithType:WebRequestApiTypeGroupMember Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            block(nil);
//            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
//            return;
        } else {
            NSMutableArray *tempArr = [NSMutableArray new];
            NSArray *members= resp.resultset[@"success"][@"response"];
            for (NSDictionary *memberInfo in members) {
                WFYUserInfo *member = [[WFYUserInfo alloc]init];
                member.userId = memberInfo[@"UserName"];
                member.name = memberInfo[@"NickName"];
                member.portraitUri = memberInfo[@"Avatar"];
                if ([memberInfo objectForKey:@"CreatedAt"] && ![[memberInfo objectForKey:@"CreatedAt"] isKindOfClass:[NSNull class]]) {
                   member.updatedAt = memberInfo[@"CreatedAt"];
                }else{
                    NSDate *dateNow = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    member.updatedAt = [formatter stringFromDate:dateNow];
                }
                //member.displayName = memberInfo[@"displayName"];
                if ([(NSNull *)(member.portraitUri) isKindOfClass:[NSNull class]] || !member.portraitUri || member.portraitUri <= 0) {
                    member.portraitUri = [AppSession defaultUserPortrait:member];
                }
                [tempArr addObject:member];
            }
            //按加成员入群组时间的升序排列
            SortForTime *sort = [[SortForTime alloc] init];
            tempArr = [sort sortForUpdateAt:tempArr order:NSOrderedDescending];
            [[WFDataBaseManager shareInstance] insertGroupMemberToDB:tempArr groupId:groupId complete:^(BOOL result) {
                if (result == YES) {
                    if (block) {
                        block(tempArr);
                    }
                }
            }];
        }
    } :^(NSError *error) {
        block(nil);
    }];
}

//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                 complete:(void (^)(BOOL))result {
    NSMutableDictionary *userIdList= [@{} mutableCopy];
    [usersId enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [userIdList setObject:obj forKey:[NSString stringWithFormat:@"user%ld",(long)(idx+1)]];
    }];
    NSDictionary *inputParams =@{
                                 @"operatorId":kUserId,
                                 @"userIdList":[AppSession dictionaryToJson:userIdList],
                                 @"groupId":groupID,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeJoinGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//退出群组
- (void)quitGroupWithUserId:(NSString *)userID
                    GroupId:(NSString *)groupID
                   complete:(void (^)(BOOL))result{
    NSDictionary *inputParams =@{
                                 @"userId":userID,
                                 @"groupId":groupID,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeQuitGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//移除群组成员
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                   complete:(void (^)(BOOL))result {
    NSMutableDictionary *userIdList= [@{} mutableCopy];
    [usersId enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [userIdList setObject:obj forKey:[NSString stringWithFormat:@"user%u",idx+1]];
    }];
    NSDictionary *inputParams =@{
                                 @"userIdList":[AppSession dictionaryToJson:userIdList],
                                 @"groupId":groupID,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeKickGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//解散群组
- (void)dismissGroupWithUserId:(NSString *)userID
                       GroupId:(NSString *)groupID
                       complete:(void (^)(BOOL))result {
    NSDictionary *inputParams = @{
                                 @"userId":userID,
                                 @"groupId":groupID,
                                 };
    _baseApi=[self WebRequestApiWithType:WebRequestApiTypeDismissGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
          [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
          result(NO);
        }else{
          result(YES);
        }
        
    } :^(NSError *error) {
        result(NO);
    }];
}

//修改群组名称
- (void)renameGroupWithGroupId:(NSString *)groupID
                    groupName:(NSString *)groupName
                     complete:(void (^)(BOOL))result {
    NSDictionary *inputParams =@{
                                 @"groupId":groupID,
                                 @"groupName":groupName,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeUpdateGroupName Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

- (void)syncGroupWithUserId:(NSString *)userId
                   complete:(void (^)(BOOL))result{
    NSDictionary *inputParams=@{
                                @"userId":userId
                                };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeSyncGroup Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        //{"success": {"successMessageCode": 1,"successMessage": "同步成功"}}
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//根据id获取通知消息
- (void)getAnnouncementByID:(NSString *)announcementId
   successCompletion:(void (^)(WFYAnnouncementModel *model))completion {
    NSDictionary *inputParams =@{
                                 @"announcementId":announcementId,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeAnnouncementInfo Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            if (completion) {
                completion(nil);
            };
        }else{
            NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
            WFYAnnouncementModel *model = [[WFYAnnouncementModel alloc]init];
            model.announcementId = announcementId;
            model.anncTopic = resultInfo[@"AnncTopic"];
            model.anncContent = resultInfo[@"AnncContent"];
            model.anncPublisher=resultInfo[@"AnncPublisher"];
            model.anncSendTime=resultInfo[@"AnncSendTime"];
            model.timeStamp =resultInfo[@"TimeStamp"];
            model.anncSummary=resultInfo[@"AnncSummary"];
            model.anncPicURL=resultInfo[@"AnncPicURL"];
            NSLog(@"%@",model.anncPicURL);
            if ([model.announcementId isEqualToString:announcementId] && completion) {
                completion(model);
            }else if (completion) {
                completion(nil);
            }
        }
    } :^(NSError *error) {
        WFYAnnouncementModel *model = [[WFDataBaseManager shareInstance] getAnnouncementByID:announcementId];
        if ([model.announcementId isEqualToString:announcementId] && completion) {
            completion(model);
        }else if (completion){
            completion(nil);
        }
        
    }];
}

//发送公告消息
- (void)sendAnncMsgWithUserId:(NSString *)userId
               AnnouncementId:(NSString *)AnnouncementId
                     complete:(void (^)(BOOL))result{
    NSDictionary *inputParams=@{
                                @"userId":userId,
                                @"AnnouncementId":AnnouncementId
                                };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeAnncMessage Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//医生端上传更新RegistrationID
- (void)adminUploadRegistrationID:(NSString *)registrationID
                           UserId:(NSString *)userId
                         complete:(void (^)(BOOL))result{
    NSDictionary *inputParams =@{
                                 @"userName":userId,
                                 @"RegistrationID":registrationID
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeAdminUploadRegistrationID Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//获取用户的快捷回复内容 type 1:医生与患者聊天消息;2,组织架构成员间聊天消息；3，群会话聊天消息
- (void)getQuickReplyMsgByType:(NSString *)type
             successCompletion:(void (^)(NSArray *arr))completion{
    NSDictionary *inputParams =@{
                                 @"quickReplyType":type
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeQuickReply Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            completion(nil);
        }else{
            NSArray *arr = [[NSArray alloc]init];
            arr = resp.resultset[@"success"][@"response"];
            completion(arr);
        }
    } :^(NSError *error) {
        completion(nil);
    }];
}

- (void)getHomePortalWithDefaultFlag:(NSString *)defaultFlag
                               Block:(void (^)(NSArray *result))block{
    NSDictionary *inputParams = @{@"defaultFlag":defaultFlag};
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeHomePortal Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            block(nil);
        }else{
            // 字典数组 -> 模型数组
            // 报错：mj_objectArrayWithKeyValuesArray:]: unrecognized selector sent to class
            //NSArray *portals = [WFYHomePortalItem mj_objectArrayWithKeyValuesArray:];
            NSMutableArray *portals = [@[] mutableCopy];
            NSArray *arr =resp.resultset[@"success"][@"response"];
            for (NSInteger i = 0; i<arr.count; i++) {
                WFYHomePortalItem *portal = [[WFYHomePortalItem alloc] init];
                portal.Name = arr[i][@"Name"];
                portal.Icon = arr[i][@"Icon"];
                portal.URL  = @"http://www.baidu.com";//arr[i][@"URL"];
                portal.Type = arr[i][@"Type"];
                [portals addObject:portal];
            }
            block(portals);
        }
    } :^(NSError *error) {
        block(nil);
    }];
    
    
    /*
    NSArray *titles = @[
                        @[@"排班管理", @"预约管理", @"工作量统计", @"绩效考核", @"患者管理", @"病历查询", @"门诊量统计", @"危机值"],
                        @[@"流程审批", @"会议记录", @"待办任务", @"请假申请", @"知识库", @"文件管理", @"邮件助手", @"合同管理"],
                        @[@"随访系统", @"CRM系统", @"健康管理"]
                        ];
    NSMutableArray *imgNames = [@[] mutableCopy];
    __block NSInteger imgIdx = 0;
    [titles enumerateObjectsUsingBlock:^(NSArray *  _Nonnull arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *sectionArr = [@[] mutableCopy];
        for (NSInteger i = 0; i<arr.count; i++) {
            [sectionArr addObject:[NSString stringWithFormat:@"home_cell_%ld", imgIdx]];
            imgIdx++;
        }
        [imgNames addObject:sectionArr];
    }];
    
    NSMutableArray *items = [@[] mutableCopy];
    
    for (NSInteger i = 0; i<titles.count; i++) {
        NSArray *sectionTitles = titles[i];
        NSArray *sectionImgNames = imgNames[i];
        for (NSInteger j = 0; j<sectionTitles.count; j++) {
            WFYHomePortalItem *item = [[WFYHomePortalItem alloc] init];
            item.Name = sectionTitles[j];
            item.Icon = sectionImgNames[j];
            item.Type = [NSString stringWithFormat:@"%ld",(long)i];
            [items addObject:item];
        }
        
    }
    if ([defaultFlag isEqualToString: @"0"]) {
        block(items);
    }
    else{
        NSMutableArray * arr =[NSMutableArray new];
        [arr addObject:items[0]];
        block(arr);
    }
     */
    
    /*
     Values of type 'NSInteger' should not be used as format arguments
     原因:
         苹果app支持arm64以后会有一个问题：NSInteger变成64位了，和原来的int （%d）不匹配，使用[NSString stringWithFormat:@“%d", integerNum]; 会报如下警告：
         Values of type 'NSInteger' should not be used as format arguments; add an explicit cast to 'long' instead
     解决办法：
         1、系统推荐方法   [NSString stringWithFormat:@“%ld", (long)integerNum];
         2、强制转换int   [NSString stringWithFormat:@"%d", (int)integerNum];
         3、转为数字对象   [NSString stringWithFormat:@“%@", @(integerNum)];
         4、使用%zd占位符  [NSString stringWithFormat:@“%zd", integerNum];  （最简单的方法）
     
     补充：
         关于%zd格式化字符，只能运行在支持C99标准的编译器中，表示对应的数字是一个size_t类型，size_t是unsigned int 的增强版，表示与机器类型相关的unsigned类型，即：
         size-t在32位系统下是unsigned int(4个字节)，在64位系统中为long unsigned int(8个字节)。
     */
}

- (void)doCollectWithCollection:(WFYCollectionModel *)collection
                       complete:(void (^)(NSString *))collectionId{
    NSDictionary *inputParams = @{
                                  @"userId":kUserId,
                                  @"collectionSourceType":collection.collectionSourceType,
                                  @"collectionSourceName":collection.collectionSourceName,
                                  @"collectionSourceId":collection.collectionSourceId
                                  };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeDoCollect Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            collectionId(nil);
        }else{
            NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
            collectionId(resultInfo[@"CollectionId"]);
        }
    } :^(NSError *error) {
        collectionId(nil);
    }];
}

//根据id获取收藏信息
- (void)getCollectionByID:(NSString *)collectionId
        successCompletion:(void (^)(WFYCollectionModel *))completion{
    NSDictionary *inputParams =@{
                                 @"collectionId":collectionId,
                                 };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeGetCollectionInfo Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            if (completion) {
                completion(nil);
            };
        }else{
            NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
            WFYCollectionModel *collection = [[WFYCollectionModel alloc]init];
            collection.collectionId = [NSString stringWithFormat:@"%@",resultInfo[@"CollectionId"]];
            collection.collectionSourceType = resultInfo[@"CollectionSourceType"];
            collection.collectionSourceName = resultInfo[@"CollectionSourceName"];
            collection.collectionSourceId   = resultInfo[@"CollectionSourceId"];
            collection.collectionDesc = resultInfo[@"CollectionDesc"];
            collection.collectionPicURL = resultInfo[@"CollectionPicURL"];
            collection.collectionTitle = resultInfo[@"CollectionTitle"];
            [[WFDataBaseManager shareInstance]insertCollectionToDB:collection];
            if ([collection.collectionId isEqualToString:collectionId] && completion) {
                completion(collection);
            }else if (completion) {
                completion(nil);
            }
        }
    } :^(NSError *error) {
        WFYCollectionModel *collection =
        [[WFDataBaseManager shareInstance] getCollectionByCollectionId:collectionId];
        completion(collection);
    }];
}

//获取我的收藏
- (void)getMyCollectionsWithBlock:(void (^)(NSMutableArray *result))block{
    NSMutableArray *tempArr = [[WFDataBaseManager shareInstance]getAllCollection];
    NSDictionary *inputParams = @{@"userId":kUserId};
    _baseApi=[self WebRequestApiWithType:WebRequestApiTypeGetMyCollection Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            block(tempArr);
        } else {
            NSArray *allCollections = resp.resultset[@"success"][@"response"];
            NSMutableArray *tempArr = [NSMutableArray new];
            if ([allCollections count] >0) {
                NSMutableArray *collections = [NSMutableArray new];
                [[WFDataBaseManager shareInstance] clearCollectionfromDB];
                for (NSDictionary *dic in allCollections) {
                    if (![dic isKindOfClass:[NSNull class]]) {
                        NSLog(@"%@",dic);
                        WFYCollectionModel *collection =[[WFYCollectionModel alloc]init];
                        collection.collectionId = dic[@"CollectionId"];
                        collection.collectionTitle = dic[@"CollectionTitle"];
                        collection.collectionDesc = dic[@"CollectionDesc"];
                        collection.collectionPicURL = dic[@"CollectionPicURL"];
                        collection.collectionSourceId = dic[@"CollectionSourceId"];
                        collection.collectionSourceName = dic[@"CollectionSourceName"];
                        collection.collectionSourceType = dic[@"CollectionSourceType"];
                        collection.timeStamp = dic[@"timeStamp"];
                        [tempArr addObject:collection];
                        [collections addObject:collection];
                    }
                }
                [[WFDataBaseManager shareInstance] insertCollectionsToDB:collections complete:^(BOOL result) {
                    if (result == YES) {
                        block(tempArr);
                    }
                }];
            }
            else{
                block(nil);
            }
        }
    } :^(NSError *error) {
        block(tempArr);
        XILog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//发送收藏转发单聊消息
- (void)sendPrivateCollectionMsgWithUserId:(NSMutableArray *)userId
                              CollectionId:(NSString *)collectionId
                                  complete:(void (^)(BOOL))result{
    NSString *toUserId = [userId componentsJoinedByString:@","];
    NSDictionary *inputParams=@{
                                @"fromUserId":kUserId,
                                @"toUserId":toUserId,
                                @"collectionId":collectionId
                                };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeSendPrivateCollectionMsg Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}

//发送收藏转发群组消息
- (void)sendGroupCollectionMsgWithUserId:(NSMutableArray *)groupId
                            CollectionId:(NSString *)collectionId
                                complete:(void (^)(BOOL))result{
    NSDictionary *inputParams=@{
                                @"fromUserId":kUserId,
                                @"toGroupId":[groupId componentsJoinedByString:@","],
                                @"collectionId":collectionId
                                };
    _baseApi = [self WebRequestApiWithType:WebRequestApiTypeSendGroupCollectionMsg Params:inputParams];
    [_baseApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            result(NO);
        }else{
            result(YES);
        }
    } :^(NSError *error) {
        result(NO);
    }];
}


@end
