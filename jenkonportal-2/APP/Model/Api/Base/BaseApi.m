//
//  BaseApi.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseApi.h"
#import "XICommonDef.h"
#import "CreatGroupApi.h"
#import "LoginApi.h"
#import "MyGroupApi.h"
#import "GroupMemberApi.h"
#import "DismissGroupApi.h"
#import "JoinGroupApi.h"
#import "QuitGroupApi.h"
#import "KickGroupApi.h"
#import "UpdateGroupNameApi.h"
#import "GetGroupInfoApi.h"
#import "UserInfoApi.h"
#import "AnncInfoApi.h"
#import "AdminUploadRegistrationIDApi.h"
#import "SyncGroupApi.h"
#import "AnncMessageApi.h"
#import "QuickReplyApi.h"
#import "HomePortalApi.h"
#import "DoCollectApi.h"
#import "GetCollectionInfoApi.h"
#import "GetMyCollectionApi.h"
#import "SendGroupCollectionMsgApi.h"
#import "SendPrivateColectionMsgApi.h"

typedef void (^Success)(ApiRespModel *);
typedef void (^Failure)(NSError *);

@interface AppXMLParser : NSObject<NSXMLParserDelegate>

@property(strong, nonatomic) NSXMLParser *parser;
- (void)parse:(Success)s :(Failure)f;

@end

@interface BaseApi ()<NSXMLParserDelegate>

@end

@implementation BaseApi
{
    NSMutableString *_xmlTmp;
    Success _s;
}

- (void)connect:(void (^)(ApiRespModel *resp))success :(void (^)(NSError *error))failure
{
    [self.webDelegate method:[self method] url:[self url] charsParams:[self charParams] constructingBodyStream:[self streamContents] onSuccess:^(id responseObject) {
        
        if (success==NULL) return;
        
        AppXMLParser *parser = [[AppXMLParser alloc] init];
        parser.parser = (NSXMLParser *)responseObject;
        [parser parse:^(ApiRespModel *resp) {
            success([self parseResultSet:resp]);
        } :^(NSError *e) {
            if (failure!=NULL) {
                failure(e);
            }
        }];
        
    } onFailure:^(NSError *error) {
        
        if (failure!=NULL) {
            failure(error);
        }
        
    }];
}

//
- (NSString *)method{return nil;}

- (NSString *)url{return nil;}

- (NSDictionary *)charParams{return nil;}

- (StreamContents)streamContents{return NULL;}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp{return webResp;};

+ (BaseApi *)WebRequestApiWithType:(WebRequestApiType)type
{
    switch (type) {
        case WebRequestApiTypeLogin:
            return [[LoginApi alloc]init];
            break;
        case WebRequestApiTypeCreatGroup:
            return [[CreatGroupApi alloc]init];
            break;
        case WebRequestApiTypeMyGroup:
            return [[MyGroupApi alloc]init];
            break;
        case WebRequestApiTypeGroupMember:
            return [[GroupMemberApi alloc]init];
            break;
        case WebRequestApiTypeDismissGroup:
            return [[DismissGroupApi alloc]init];
            break;
        case WebRequestApiTypeJoinGroup:
            return [[JoinGroupApi alloc]init];
            break;
        case WebRequestApiTypeQuitGroup:
            return [[QuitGroupApi alloc]init];
            break;
        case WebRequestApiTypeKickGroup:
            return [[KickGroupApi alloc]init];
            break;
        case WebRequestApiTypeUpdateGroupName:
            return [[UpdateGroupNameApi alloc]init];
            break;
        case WebRequestApiTypeGetGroupInfo:
            return [[GetGroupInfoApi alloc]init];
            break;
        case WebRequestApiTypeGetUserInfo:
            return [[UserInfoApi alloc]init];
            break;
        case WebRequestApiTypeAnnouncementInfo:
            return [[AnncInfoApi alloc]init];
            break;
        case WebRequestApiTypeAdminUploadRegistrationID:
            return [[AdminUploadRegistrationIDApi alloc]init];
            break;
        case WebRequestApiTypeSyncGroup:
            return [[SyncGroupApi alloc]init];
            break;
        case WebRequestApiTypeAnncMessage:
            return [[AnncMessageApi alloc]init];
            break;
        case WebRequestApiTypeQuickReply:
            return [[QuickReplyApi alloc]init];
            break;
        case WebRequestApiTypeHomePortal:
            return [[HomePortalApi alloc]init];
            break;
        case WebRequestApiTypeDoCollect:
            return [[DoCollectApi alloc]init];
            break;
        case WebRequestApiTypeGetCollectionInfo:
            return [[GetCollectionInfoApi alloc]init];
            break;
        case WebRequestApiTypeGetMyCollection:
            return [[GetMyCollectionApi alloc]init];
            break;
        case WebRequestApiTypeSendPrivateCollectionMsg:
            return [[SendPrivateColectionMsgApi alloc]init];
            break;
        case WebRequestApiTypeSendGroupCollectionMsg:
            return [[SendGroupCollectionMsgApi alloc]init];
            break;
        default:
            return [[BaseApi alloc]init];
            break;
    }
}

@end


@implementation AppXMLParser
{
    NSMutableString *_xmlTmp;
    Success _s;
    Failure _f;
}

- (void)setParser:(NSXMLParser *)parser
{
    _parser = parser;
    
    parser.delegate = self;
}

- (void)parse:(Success)s :(Failure)f
{
    _s = s;
    _f = f;
    [_parser parse];
}

// MARK: - NSXMLParserDelegate
// 1. 开始文档 - 准备工作
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _xmlTmp = [[NSMutableString alloc] initWithString:@""];
}

// 2. 开始节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // NSLog(@"2. 开始节点 %@ %@", elementName, attributeDict);
}

// 3. 发现文字
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_xmlTmp appendString:string];
    // NSLog(@"==> %@", string);
}

// 4. 结束节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // NSLog(@"4. 结束节点 %@", elementName);
}
// 5. 结束文档 - 解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    // NSLog(@"5. 解析结束");
    id resultset = [NSJSONSerialization JSONObjectWithData:[_xmlTmp dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    ApiRespModel *resp = [[ApiRespModel alloc] init];
    resp.errno_ = 0;
    resp.errmsg = @"";
    resp.resultset = resultset;
    
    _s(resp);
    
    // release
    _xmlTmp = nil;
    _s = NULL;
    _f = NULL;
}

// 6. 错误处理
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    _f(parseError);
    XILog(@"解析错误 %@", parseError);
}

@end
