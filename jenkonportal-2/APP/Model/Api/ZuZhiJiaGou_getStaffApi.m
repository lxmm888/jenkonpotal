//
//  ZuZhiJiaGou_getStaffApi.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/23.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "ZuZhiJiaGou_getStaffApi.h"
#import "AppConf.h"
#import "StaffModel.h"
#import "SVProgressHUD.h"

@implementation ZuZhiJiaGou_getStaffApi

- (NSString *)url
{
    return kStaffGetUrl;
}

- (NSString *)method
{
    return GET;
}

- (NSDictionary *)charParams
{
    return @{@"departmentCatalogId":@(_departmentId)};
}

/**
 *根据部门获取用户信息成功返回值
 {
 success =     {
     response =         (
             {
             Avatar = "http://www.jenkon.vip/Upload//Global/jpg/Admin/administrator.png";
             DepartmentId = 0;
             Email = "administrator@powereasy.net";
             NickName = administrator;
             SiteId = 1;
             UserID = 1;
             UserName = administrator;
             },
             {
             Avatar = "http://www.jenkon.vip";
             DepartmentId = 10;
             Email = "zhaoli@gmail.com";
             NickName = "\U8d75\U7acb";
             SiteId = 1;
             UserID = 45;
             UserName = zhaoli;
             }
         );
     successMessage = "\U83b7\U53d6\U7528\U6237\U4fe1\U606f\U6210\U529f";
     successMessageCode = 1;
     };
 }
 **/
- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    //add by zl 20170816  返回值存在error和success两种情况
    if (!(webResp.resultset[@"success"]) && (webResp.resultset[@"error"])) {
        [SVProgressHUD showErrorWithStatus:webResp.resultset[@"error"][@"errorMessage"]];
        return nil;
    }
    else{
        NSArray *arr = webResp.resultset[@"success"][@"response"];
        //NSArray *arr = webResp.resultset;
        NSMutableArray *re = [@[] mutableCopy];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [re addObject:[self staff:obj]];
        }];
        webResp.resultset = @{self.staffsKeyName:re};
        
        return webResp;
    }
}

- (StaffModel *)staff:(NSDictionary *)dict
{
    StaffModel *staff = [[StaffModel alloc] init];
    staff.uid = [dict[@"UserID"] integerValue];
    staff.usrname = dict[@"UserName"];
    staff.nickname = dict[@"NickName"];
    staff.email = dict[@"Email"];
    staff.avatarUri = [dict[@"Avatar"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    return staff;
}

- (NSString *)staffsKeyName
{
    return @"staffs";
}

@end
