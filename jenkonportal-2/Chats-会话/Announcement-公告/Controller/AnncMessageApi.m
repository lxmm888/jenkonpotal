//
//  AnncMessageApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/28.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "AnncMessageApi.h"
#import "AppConf.h"

@implementation AnncMessageApi

- (NSString *)url
{
    return kAnncMessageApiUrl;
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
