//
//  DepartmentModel.h
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StaffModel;
@interface DepartmentModel : NSObject

@property (assign, nonatomic) NSInteger uid;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *children;

@property (assign, nonatomic) NSInteger parentId;
@property (assign, nonatomic) NSInteger left;
@property (assign, nonatomic) NSInteger right;
@property (assign, nonatomic) NSInteger depth;

@property (strong, nonatomic) NSArray<StaffModel *> *staffs;

@end
