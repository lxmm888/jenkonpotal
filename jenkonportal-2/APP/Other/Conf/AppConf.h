//
//  AppConf.h
//  jenkonportal
//
//  Created by 冯文林  on 17/5/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#ifndef AppConf_h
#define AppConf_h

// 融云app key
#define rongIMAppKey @"8luwapkv8siml" //kj7swf8okycq2

// 通知名
#define kNotiName_didUsrChanged @"didUsrChanged"
#define kNotiName_didPortalChanged @"didPortalChanged"

// api url
// alter by zl 20170815 请求服务的url有变化，将PhoneWebService.asmx修改为PhoneService.asmx
#define kLoginApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/Login"
#define kDepartmentGetUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetOrganizationalStructure"
#define kStaffGetUrl  @"http://jenkon.vip:8078/PhoneService.asmx/GetUserListByDepartmentId"
#define kUsrInfoUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetUserByName"//根据用户名获取用户信息
#define kTokenApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetToken" //add by zl 20170817 获取Token的url
#define kCreateGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/CreateChatGroup"
#define kMyGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetMyGroup"  //add 20170907 获取我所在的所有群组
#define kGroupMemberApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetGroupMember"  //add 20170907 根据群组ID获取群组成员信息
#define kDismissGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/DismissGroup" //add 20170908 解散群组
#define kJoinGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/JoinGroup" //add 20170908 加入群组
#define kQuitGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/QuitGroup" //add 20170908 退出群组
#define kKickGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/KickGroup" //add 20170908 移除群组成员
#define kUpdateGroupNameApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/UpdateGroupInfo"
#define kGetGroupInfoApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetGroupInfo"
#define kSyncGroupApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/SyncGroup" //同步用户所属群组
#define kQuickReplyApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetQuickReply" //获取用户的快捷回复内容
#define kHomePortalApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetHomePortal" //获取办公门户内容
#define kDoCollectApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/DoCollect" //我的收藏
#define kGetCollectionInfoApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetCollectionInfo" //我的收藏
#define kGetMyCollectionApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetMyCollection" //我的收藏
#define kSendPrivateCollectionMsgApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/SendPrivateCollectionMsg"
#define kSendGroupCollectionMsgApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/SendGroupCollectionMsg"

//公告
#define kAnncInfoApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/GetAnnouncementById"
#define kAnncMessageApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/SendAnncMsg" //发送公告消息

// 极光推送 AppKey
#define JPushAppKey @"bc535cac15cb46959b043e49"
#define JPushChannel @"App Store"
#define kAdminUploadRegistrationIDApiUrl @"http://jenkon.vip:8078/PhoneService.asmx/AdminUploadRegistrationID"//医生端上传更新RegistrationID

#endif /* AppConf_h */
