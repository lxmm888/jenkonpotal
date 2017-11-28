//
//  CreatGroupApi.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/28.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "CreatGroupApi.h"
#import "AppConf.h"

@implementation CreatGroupApi

- (NSString *)url{
    return kCreateGroupApiUrl;
}

- (NSString *)method{
    return GET;
}

- (NSDictionary *)charParams{
//    return @{
//             @"userId":_usrname,
//             @"userIdList":_userIdList,
//             @"groupName":_groupName
//             };
    return self.inputParams;
}

- (ApiRespModel *)parseResultSet:(ApiRespModel *)webResp
{
    return [super parseResultSet:webResp];
}

@end
