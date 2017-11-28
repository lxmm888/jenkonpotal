//
//  QuickReplyApi.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "QuickReplyApi.h"

@implementation QuickReplyApi


- (NSString *)url
{
    return kQuickReplyApiUrl;
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
