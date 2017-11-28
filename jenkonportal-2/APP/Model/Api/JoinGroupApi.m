//
//  JoinGroupApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/12.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "JoinGroupApi.h"
#import "AppConf.h"

@implementation JoinGroupApi

- (NSString *)url{
    return kJoinGroupApiUrl;
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
