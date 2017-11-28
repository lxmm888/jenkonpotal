   //
//  RongIMKitHelper.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/17.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "RongIMKitHelper.h"
#import "UsrInfoApi.h"
#import "APPWebMgr.h"
#import "XICommonDef.h"

static RongIMKitHelper *_helper;

@implementation RongIMKitHelper
{
    UsrInfoApi *_usrInfoApi;
    APPWebMgr *_webMgr;
}

#pragma mark - RCIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion
{
    _usrInfoApi.usrname = userId;
    [_usrInfoApi connect:^(ApiRespModel *resp) {
        
        NSDictionary *usrInfo = resp.resultset;
        completion([[RCUserInfo alloc] initWithUserId:userId name:usrInfo[@"NickName"] portrait:[usrInfo[@"Avatar"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]);
        
    } :^(NSError *error) {
        XILog(@"%@", error.localizedDescription);
    }];
}


+ (instancetype)shareHelper
{
    if (_helper==nil) {
        _helper = [[RongIMKitHelper alloc] init];
    }
    return _helper;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [super allocWithZone:zone];
    });
    return _helper;
}

- (instancetype)init
{
    if (self = [super init]) {
        _usrInfoApi = [[UsrInfoApi alloc] init];
        _webMgr = [APPWebMgr manager];
        _usrInfoApi.webDelegate = _webMgr;
    }
    return self;
}

@end
