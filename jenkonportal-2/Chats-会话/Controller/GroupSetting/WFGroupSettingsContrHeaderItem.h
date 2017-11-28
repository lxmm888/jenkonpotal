//
//  WFGroupSettingsContrHeaderItem.h
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/31.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UsrModel.h"
#import <UIKit/UIKit.h>
#import <RongIMLib/RCUserInfo.h>

@protocol WFGroupSettingsContrHeaderItemDelegate;

@interface WFGroupSettingsContrHeaderItem : UICollectionViewCell

/** 头像 */
@property (nonatomic, strong) UIImageView *ivAva;
/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;
/**  */
@property (nonatomic, strong) UIButton *btnImg;
/** userid */
@property (nonatomic, copy) NSString *userId;
/** 代理对象 */
@property (nonatomic, weak) id<WFGroupSettingsContrHeaderItemDelegate> delegate;

- (void)setUserModel:(RCUserInfo *)userModel;

@end

@protocol WFGroupSettingsContrHeaderItemDelegate <NSObject>

- (void)deleteTipButtonClicked:(WFGroupSettingsContrHeaderItem *)item;

@end
