//
//  AdminUploadRegistrationIDApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "AdminUploadRegistrationIDApi.h"
#import "AppConf.h"

@implementation AdminUploadRegistrationIDApi

- (NSString *)url
{
    return kAdminUploadRegistrationIDApiUrl;
}

- (NSString *)method
{
    return GET;
}

- (NSDictionary *)charParams
{
    return self.inputParams;
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
