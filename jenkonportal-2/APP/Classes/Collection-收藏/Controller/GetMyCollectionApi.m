//
//  GetMyCollectionApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/15.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "GetMyCollectionApi.h"

@implementation GetMyCollectionApi

- (NSString *)url
{
    return kGetMyCollectionApiUrl;
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
