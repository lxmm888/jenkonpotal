//
//  CreateGroupContr.h
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/25.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"

@class StaffModel;
@interface CreateGroupContr : BaseContr<UITextFieldDelegate, UIActionSheetDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype)createGroupViewController;

@property (nonatomic, strong) NSMutableArray *GroupMemberIdList;
@property (nonatomic, strong) NSMutableArray *GroupMemberList;

@end
