//
//  UsrInfoApi.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/6/2.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UsrInfoApi.h"
#import "AppConf.h"

@implementation UsrInfoApi

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
    return @{@"administratorName":_usrname};
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
