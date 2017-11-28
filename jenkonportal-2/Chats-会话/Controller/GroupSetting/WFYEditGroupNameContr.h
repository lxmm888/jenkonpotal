//
//  WFYEditGroupNameContr.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"
#import "WFGroupInfo.h"

@interface WFYEditGroupNameContr : BaseContr<UITextFieldDelegate>

/**
 *  修改群名称页面的初始化方法
 *
 *  @return 实例对象
 */
+ (instancetype)editGroupNameContr;

/**
 *  修改群名称的textFiled
 */
@property(nonatomic, strong) UITextField *groupNameTextField;

/**
 *   群信息
 */
@property(nonatomic, strong) WFGroupInfo *groupInfo;

@end
