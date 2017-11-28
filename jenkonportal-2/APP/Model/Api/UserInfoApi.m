//
//  UserInfoApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/20.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UserInfoApi.h"
#import "AppConf.h"

@implementation UserInfoApi

- (NSString *)url
{
    return kUsrInfoUrl;
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
