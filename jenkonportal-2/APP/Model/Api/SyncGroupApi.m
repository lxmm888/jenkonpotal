//
//  SyncGroupApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/26.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "SyncGroupApi.h"
#import "AppConf.h"

@implementation SyncGroupApi

- (NSString *)url
{
    return kSyncGroupApiUrl;
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
