//
//  WFYGroupAnnouncementContr.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"
@class UITextViewAndPlaceholder;

@interface WFYGroupAnnouncementContr : BaseContr<UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITextViewAndPlaceholder *AnnouncementContent;

@property (nonatomic, strong) NSString *GroupId;

@end
