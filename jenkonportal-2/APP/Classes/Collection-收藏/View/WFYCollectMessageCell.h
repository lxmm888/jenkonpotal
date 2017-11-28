//
//  WFYCollectMessageCell.h
//  jenkonportal
//
//  Created by 赵立 on 2017/11/16.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYCollectMessage.h"
#import <RongIMKit/RongIMKit.h>

/*!
 收藏转发消息Cell
 */
@interface WFYCollectMessageCell : RCMessageCell

/*!
 文本内容的Label
 */
@property(strong, nonatomic) UILabel *textLabel;

/*!
 附加内容的Label
 */
@property(strong, nonatomic) UILabel *extraLabel;

/*!
 配图View
 */
@property(nonatomic, strong) UIImageView *picView;

/*!
 背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 根据消息内容获取显示的尺寸
 
 @param message 消息内容
 
 @return 显示的View尺寸
 */
+ (CGSize)getBubbleBackgroundViewSize:(WFYCollectMessage *)message;

@end
