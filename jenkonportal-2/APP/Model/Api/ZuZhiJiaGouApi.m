//
//  ZuZhiJiaGouApi.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "ZuZhiJiaGouApi.h"
#import "DepartmentModel.h"
#import "AppConf.h"
#import "SVProgressHUD.h"

@implementation ZuZhiJiaGouApi

- (NSString *)url
{
    return kDepartmentGetUrl;
}

- (NSString *)method
{
    //return POST;
    return GET;//alter by zl 20170816
}

//add by zl 20170816 重写父类字符型入参的Get方法
//接口文档调整后，获取组织架构需要传入参数siteId
- (NSDictionary *)charParams
{
    return @{
             @"siteId":_siteId
             };
}


/**
 * 组织架构回参
   20170918前
 {
     success =     {
             response =         (
                 {
                     DepartmentId = 1;
                     DepartmentName = "\U5065\U5eb7\U533b\U7597";
                     Depth = 1;
                     Left = 0;
                     ParentId = "<null>";
                     Right = 9;
                     childDeptList =                 (
                         {
                             DepartmentId = 1;
                             DepartmentName = "\U79fb\U52a8\U533b\U7597";
                             Depth = 2;
                             Left = 7;
                             ParentId = "<null>";
                             Right = 8;
                             childDeptList =                 (
                             );
                         }
                     );
                 }
             );
         successMessage = "\U83b7\U53d6\U7ec4\U7ec7\U67b6\U6784\U6210\U529f";
         successMessageCode = 1;
     };
 }
 20170918后
 {
     DepartmentId = 1;
     DepartmentName = "\U5065\U5eb7\U533b\U7597";
     Depth = 0;
     Left = 1;
     ParentId = "<null>";
     Right = 10;
     childDeptList =     (
         {
                 DepartmentId = 7;
                 DepartmentName = "\U4e13\U5bb6\U7ec4";
                 Depth = 1;
                 Left = 6;
                 ParentId = "<null>";
                 Right = 7;
                 childDeptList =             (
                 );
         },
     );
 }

 
 使用{}包起来的部分，应该赋值给字典；使用()包起来的部分应该赋值给数组
 数组对象，可以使用类似deptDict[@"DepartmentId"]的形式来取字典值；字典对象，可以使用[下标]的形式来取值
 **/
- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    //add by zl 20170816  返回值存在error和success两种情况
    if (!(webResp.resultset[@"success"]) && (webResp.resultset[@"error"])) {
        [SVProgressHUD showErrorWithStatus:webResp.resultset[@"error"][@"errorMessage"]];
        return nil;
    }
    else{
        //alter by zl 20170816
        //NSArray *arr = webResp.resultset;
//        NSArray *arr = webResp.resultset[@"success"][@"response"];
//        DepartmentModel *dept = [self department:arr[0]];
        NSDictionary *dic = webResp.resultset[@"success"][@"response"];
        DepartmentModel *dept = [self department:dic];
        webResp.resultset = @{self.departmentKeyName:dept};
        return webResp;
    }
}

- (DepartmentModel *)department:(NSDictionary *)deptDict
{
    DepartmentModel *dept = [[DepartmentModel alloc] init];
    dept.uid = [deptDict[@"DepartmentId"] integerValue];
    dept.name = deptDict[@"DepartmentName"];
    if (deptDict[@"childDeptList"]!=nil) {
        NSArray *children = deptDict[@"childDeptList"];
        
        NSMutableArray *arr = [@[] mutableCopy];
        [children enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arr addObject:[self department:obj]];
        }];
        dept.children = arr;
        
    }
    return dept;
}

- (NSString *)departmentKeyName
{
    return @"department";
}

@end
