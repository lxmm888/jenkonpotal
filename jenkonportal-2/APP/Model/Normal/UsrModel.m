//
//  UsrModel.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UsrModel.h"

@implementation UsrModel

#define key_usrname @"usrname"
#define key_nickname @"nickname"
#define key_siteid @"siteId"
#define key_portraitUri @"portraitUri"
#define key_token @"token"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_usrname forKey:key_usrname];
    [aCoder encodeObject:_nickname forKey:key_nickname];
    [aCoder encodeObject:_siteId forKey:key_siteid];
    [aCoder encodeObject:_portraitUri forKey:key_portraitUri];
    [aCoder encodeObject:_token forKey:key_token];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self) {
        _usrname = [aDecoder decodeObjectForKey:key_usrname];
        _nickname = [aDecoder decodeObjectForKey:key_nickname];
        _siteId = [aDecoder decodeObjectForKey:key_siteid];
        _portraitUri = [aDecoder decodeObjectForKey:key_portraitUri];
        _token = [aDecoder decodeObjectForKey:key_token];
    }
    return self;
}

@end
