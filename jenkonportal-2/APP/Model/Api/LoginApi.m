//
//  LoginApi.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "LoginApi.h"
#import "AppConf.h"

@implementation LoginApi

- (NSString *)url
{
    return kLoginApiUrl;
}

- (NSString *)method
{
    return GET;
}

- (NSDictionary *)charParams
{
    return @{
             @"LoginAdminName":_usrname,
             @"LoginAdminPassword":_pwd
             };
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
