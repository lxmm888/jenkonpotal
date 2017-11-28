//
//  WFYAnnouncementMessage.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@class WFYAnnouncementModel;


/*!
 公告消息的类型名
 */
#define WFYAnnouncementMessageTypeIdentifier @"WFY:AnncMsg"

/*!
 发布公告用的自定义消息类
 此消息会进行存储并计入未读消息数。
 */
@interface WFYAnnouncementMessage : RCMessageContent<NSCoding>

/*!
 公告的标题
 */
@property(nonatomic, strong) NSString *anncTopic;

/*!
 公告的发布者
 */
@property(nonatomic, strong) NSString *anncPublisher;

/*!
 公告的Id
 */
@property(nonatomic, strong) NSString *announcementId;

/*!
 公告的附加信息
 */
@property(nonatomic, strong) NSString *extra;


/*!
 初始化公告消息
 
 @param anncTopic 公告标题
 @param announcementId 公告id
 
 @return        测试消息对象
 */
+ (instancetype)messageWithAnncTopic:(NSString *)anncTopic
                  AnnouncementId:(NSString *)announcementId;

@end
