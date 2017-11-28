//
//  DismissGroupApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "DismissGroupApi.h"
#import "AppConf.h"

@implementation DismissGroupApi

- (NSString *)url{
    return kDismissGroupApiUrl;
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
