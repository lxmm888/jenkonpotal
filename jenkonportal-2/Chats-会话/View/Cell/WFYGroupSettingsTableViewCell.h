//
//  WFYGroupSettingsTableViewCel.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFYBaseSettingTableViewCell.h"
@class WFGroupInfo;

#define WFYGroupSettingsTableViewCellGroupNameTag 999
#define WFYGroupSettingsTableViewCellGroupPortraitTag 1000
#define SwitchButtonTag  1111

@interface WFYGroupSettingsTableViewCell : WFYBaseSettingTableViewCell
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath andGroupInfo:(WFGroupInfo *)groupInfo;
@end
