//
//  GroupMemberApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/7.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "GroupMemberApi.h"
#import "AppConf.h"

@implementation GroupMemberApi

- (NSString *)url{
    return kGroupMemberApiUrl;
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
