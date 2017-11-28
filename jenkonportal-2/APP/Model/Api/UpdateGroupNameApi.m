//
//  UpdateGroupNameApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UpdateGroupNameApi.h"
#import "AppConf.h"

@implementation UpdateGroupNameApi

- (NSString *)url{
    return kUpdateGroupNameApiUrl;
}

- (NSString *)method{
    return GET;
}

- (NSDictionary *)charParams{
    return self.inputParams;
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
