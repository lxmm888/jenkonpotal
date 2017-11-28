//
//  AnncInfoApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/21.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "AnncInfoApi.h"
#import "AppConf.h"

@implementation AnncInfoApi

- (NSString *)url
{
    return kAnncInfoApiUrl;
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
