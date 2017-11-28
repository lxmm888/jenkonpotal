//
//  WFGroupSettingsContr.h
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/30.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"
#import "WFGroupInfo.h"
#import <RongIMKit/RongIMKit.h>
#import "WFYBaseSettingTableViewCell.h"

@interface WFGroupSettingsContr : BaseContr<UITableViewDelegate,
                                            UITableViewDataSource,
                                            UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UIActionSheetDelegate,
                                            WFYBaseSettingTableViewCellDelegate
                                            >

+ (instancetype)groupSettingsContr;

@property(nonatomic, strong) WFGroupInfo *Group;

@end
