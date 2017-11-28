//
//  WFYCollectMessage.h
//  jenkonportal
//
//  Created by 赵立 on 2017/11/16.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
/*!
 收藏转发消息的类型名
 */
#define WFYCOllectMessageTypeIdentifier @"WFY:COllectMsg"

/*!
 收藏转发消息类
 
 @discussion 收藏转发消息类，此消息会进行存储并计入未读消息数。
 */
@interface WFYCollectMessage : RCMessageContent



/*!
 收藏转发消息文本的内容
 */
@property(nonatomic, strong) NSString *content;

/*!
 收藏对象Id
 */
@property(nonatomic, strong) NSString *collectionId;

/*!
 收藏转发消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化测试消息
 
 @param content 文本内容
 @return        收藏转发消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content
                      CollectionId:(NSString *)collectionId;

@end
