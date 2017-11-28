//
//  ZuZhiJiaGouApi.h
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseApi.h"

@interface ZuZhiJiaGouApi : BaseApi

@property (copy, readonly, nonatomic) NSString *departmentKeyName;
@property (copy, nonatomic) NSString *siteId; //add by zl 20170816 所属平台Id

@end
