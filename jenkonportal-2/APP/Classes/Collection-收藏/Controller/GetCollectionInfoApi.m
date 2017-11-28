//
//  GetCollectionInfoApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/14.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "GetCollectionInfoApi.h"

@implementation GetCollectionInfoApi

- (NSString *)url
{
    return kGetCollectionInfoApiUrl;
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
