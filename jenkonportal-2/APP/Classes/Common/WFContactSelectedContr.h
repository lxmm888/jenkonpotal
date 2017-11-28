//
//  QQContactViewController.h
//  MTreeViewFramework
//
//  Created by Micker on 16/3/31.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "BaseTreeViewController.h"

@interface WFContactSelectedContr : BaseTreeViewController

// 导航栏标题
@property(nonatomic, strong) NSString *titleStr;

// 添加群组成员
@property(nonatomic, strong) NSMutableArray *addGroupMembers;

// 删除群组成员
@property(nonatomic, strong) NSMutableArray *delGroupMembers;

// 多选用于创建群组
@property (nonatomic, assign) BOOL forCreatingGroup;

// 多选用于创建讨论组
@property (nonatomic, assign) BOOL forCreatingDiscussionGroup;

// 是否允许多选
@property BOOL isAllowsMultipleSelection;

@property(nonatomic, strong) NSString *groupId;

@end
