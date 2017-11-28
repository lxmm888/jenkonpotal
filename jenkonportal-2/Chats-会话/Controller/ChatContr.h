//
//  ChatContr.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/10.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface ChatContr : RCConversationViewController

/**
 *  会话数据模型
 */
@property(strong, nonatomic) RCConversationModel *conversation;
@property BOOL needPopToRootView;

@end
