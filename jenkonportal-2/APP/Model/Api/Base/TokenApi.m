//
//  TokenApi.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/17.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "TokenApi.h"
#import "AppConf.h"

@implementation TokenApi

- (NSString *)url{
    return kTokenApiUrl;
}

- (NSString *)method{
    return GET;
}

- (NSDictionary *)charParams{
    return @{
             @"administratorName":_usrname
             };
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
