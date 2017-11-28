//
//  WFYAnnouncementPopupWindow.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/30.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"

@protocol WFYAnnouncementPopupWindowDelegate;

@interface WFYAnnouncementPopupWindow : BaseContr

@property(nonatomic,weak)  id<WFYAnnouncementPopupWindowDelegate>  delegate;

@property(nonatomic,strong) NSIndexPath *indexPath;

@property(nonatomic,strong) NSString *announcementId;

@end

@protocol WFYAnnouncementPopupWindowDelegate <NSObject>

- (void)deleteAnncMsgClicked:(NSIndexPath *)indexPath;

@end
