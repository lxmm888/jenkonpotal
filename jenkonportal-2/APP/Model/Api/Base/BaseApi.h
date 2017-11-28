//
//  BaseApi.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiWebDelegate.h"

typedef void (^StreamContents)(id<AFMultipartFormData>);

typedef NS_ENUM(NSUInteger,WebRequestApiType){
    WebRequestApiTypeLogin,
    WebRequestApiTypeToken,
    WebRequestApiTypeCreatGroup,
    WebRequestApiTypeMyGroup,
    WebRequestApiTypeGroupMember,
    WebRequestApiTypeDismissGroup,
    WebRequestApiTypeJoinGroup,
    WebRequestApiTypeQuitGroup,
    WebRequestApiTypeKickGroup,
    WebRequestApiTypeUpdateGroupName,
    WebRequestApiTypeGetGroupInfo,
    WebRequestApiTypeGetUserInfo,
    WebRequestApiTypeAnnouncementInfo,
    WebRequestApiTypeAdminUploadRegistrationID,
    WebRequestApiTypeSyncGroup,
    WebRequestApiTypeAnncMessage,
    WebRequestApiTypeQuickReply,
    WebRequestApiTypeHomePortal,
    WebRequestApiTypeDoCollect,
    WebRequestApiTypeGetCollectionInfo,
    WebRequestApiTypeGetMyCollection,
    WebRequestApiTypeSendPrivateCollectionMsg,
    WebRequestApiTypeSendGroupCollectionMsg
};

@interface BaseApi : NSObject

// 网络代理对象
@property (weak, nonatomic) id<ApiWebDelegate> webDelegate;
// 入参
@property (copy, nonatomic) NSDictionary * inputParams;
// 开始连接
- (void)connect:(void (^)(ApiRespModel *resp))success :(void (^)(NSError *error))failure;

#pragma mark - 抽象方法，由子类实现
// url
- (NSString *)url;
// GET/POST
- (NSString *)method;
// 字符型入参
- (NSDictionary *)charParams;
// 上传流
- (StreamContents)streamContents;
// 解析服务器的返回数据
- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp;


+ (BaseApi *)WebRequestApiWithType:(WebRequestApiType)type;

@end
