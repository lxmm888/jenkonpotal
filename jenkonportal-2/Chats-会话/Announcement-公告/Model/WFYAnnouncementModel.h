//
//  WFYAnnouncementModel.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFYAnnouncementModel : NSObject

#define kStandardFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]]
#define kTopLabelFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-2]
#define kTitleLabelFont [UIFont boldSystemFontOfSize:[AppFontMgr standardFontSize]+2]
#define kBottomLabelFont  [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+1]

/** 文字/图片数据***/
/** 公告id */
@property (nonatomic,strong) NSString *announcementId;
/** 公告标题 */
@property (nonatomic, strong) NSString *anncTopic;
/** 通知创建人  应该理解为用户名 */
@property (nonatomic, strong) NSString *anncPublisher;
/** 通知内容 */
@property (nonatomic, strong) NSString *anncContent;
/** 通知发送时间 */
@property (nonatomic, strong) NSString *anncSendTime;
/** 时间戳 */
@property (nonatomic, strong) NSString *timeStamp;
/** 摘要 */
@property (nonatomic, strong) NSString *anncSummary;
/** 配图 */
@property (nonatomic, strong) NSString *anncPicURL;
///** 链接地址 */
//@property (nonatomic, strong) NSString *anncURL;

/** frame数据***/
/** 发布时间frame */
@property (nonatomic, assign) CGRect topFrame;
/** 标题的frame */
@property (nonatomic, assign) CGRect titleFrame;
/** 发布者的frame */
@property (nonatomic, assign) CGRect publisherFrame;
/** 配图的frame */
@property (nonatomic, assign) CGRect imageFrame;
/** 摘要的frame */
@property (nonatomic, assign) CGRect descFrame;
/** 分隔线的frame */
@property (nonatomic, assign) CGRect lineFrame;
/** 底部“详情”的frame */
@property (nonatomic, assign) CGRect bottomLabelFrame;
/** 底部图标的frame */
@property (nonatomic, assign) CGRect rightItemFrame;
/** 容器的frame */
@property (nonatomic, assign) CGRect boxViewFrame;

/** cell的高度 */
@property (nonatomic, assign) CGFloat cellHeight;

@end
