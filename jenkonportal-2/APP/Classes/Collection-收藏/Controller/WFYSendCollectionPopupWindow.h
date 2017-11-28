//
//  WFYSendCollectionPopupWindow.h
//  jenkonportal
//
//  Created by 赵立 on 2017/11/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"

@protocol WFYSendCollectionPopupWindowDelegate;

@interface WFYSendCollectionPopupWindow : BaseContr

@property(nonatomic,weak)  id<WFYSendCollectionPopupWindowDelegate>  delegate;

@property(nonatomic,strong) NSIndexPath *indexPath;

@property(nonatomic,strong) NSString *collectionId;

@end

@protocol WFYSendCollectionPopupWindowDelegate <NSObject>

- (void)sendTransmitCollectionMsgClicked:(NSIndexPath *)indexPath WithLeaveWord:(NSString *)leaveWord;

@end
