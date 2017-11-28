//
//  KickGroupApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/27.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "KickGroupApi.h"
#import "AppConf.h"

@implementation KickGroupApi

- (NSString *)url{
    return kKickGroupApiUrl;
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
