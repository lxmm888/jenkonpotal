//
//  HomePortalApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/10.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "HomePortalApi.h"
#import "AppConf.h"

@implementation HomePortalApi

- (NSString *)url
{
    return kHomePortalApiUrl;
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
