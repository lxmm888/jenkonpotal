//
//  WFYAnnouncementMessage.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnnouncementMessage.h"

@implementation WFYAnnouncementMessage

///初始化
+ (instancetype)messageWithAnncTopic:(NSString *)anncTopic
                      AnnouncementId:(NSString *)announcementId{
    WFYAnnouncementMessage *anncMsg = [[WFYAnnouncementMessage alloc]init];
    if (anncMsg) {
        anncMsg.anncTopic = anncTopic;
        anncMsg.announcementId = announcementId;
    }
    return anncMsg;
}

#pragma mark 编解码协议 RCMessageCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.anncTopic = [aDecoder decodeObjectForKey:@"anncTopic"];
        self.anncPublisher = [aDecoder decodeObjectForKey:@"anncPublisher"];
        self.announcementId = [aDecoder decodeObjectForKey:@"announcementId"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.anncTopic forKey:@"anncTopic"];
    [aCoder encodeObject:self.anncPublisher forKey:@"anncPublisher"];
    [aCoder encodeObject:self.announcementId forKey:@"announcementId"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
}

//将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.anncTopic forKey:@"anncTopic"];
    [dataDict setObject:self.anncPublisher forKey:@"anncPublisher"];
    [dataDict setObject:self.announcementId forKey:@"announcementId"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    //继承的属性
    if (self.senderUserInfo) {
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [userInfoDic setObject:self.senderUserInfo.name
                 forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [userInfoDic setObject:self.senderUserInfo.portraitUri
                 forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [userInfoDic setObject:self.senderUserInfo.userId
                 forKeyedSubscript:@"id"];
        }
        [dataDict setObject:userInfoDic forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data{
    if (data) {
        __autoreleasing NSError *error = nil;
        
        NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
        if (dictionary) {
            self.anncTopic = dictionary[@"anncTopic"];
            self.anncPublisher = dictionary[@"anncPublisher"];
            self.announcementId = dictionary[@"announcementId"];
            self.extra = dictionary[@"extra"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}

/*!
 返回消息的类型名
 
 @return 消息的类型名
 
 @discussion 定义的消息类型名，需要在各个平台上保持一致，以保证消息互通。
 
 @warning 请勿使用@"RC:"开头的类型名，以免和SDK默认的消息名称冲突
 */
+ (NSString *)getObjectName{
    return WFYAnnouncementMessageTypeIdentifier;
}

#pragma mark 存储协议 RCMessagePersistentCompatible
///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark 内容摘要协议 RCMessageContentView（可选）
/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return self.anncTopic;
}

@end
