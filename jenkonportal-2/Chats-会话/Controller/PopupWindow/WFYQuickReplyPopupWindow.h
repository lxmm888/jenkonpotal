//
//  WFYQuickReplyPopupWindow.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/30.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"
#import <RongIMKit/RongIMKit.h>

@interface WFYQuickReplyPopupWindow : BaseContr

@property(assign,nonatomic) RCConversationType rConversationType;
@property(strong,nonatomic) NSString *sTargetId;

@end
