//
//  GroupChatsHelper.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/24.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "GroupChatsHelper.h"
#import "FMDB.h"

static GroupChatsHelper *_helper;

#define _groupChatsCacheFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"groupchats.db"]

@implementation GroupChatsHelper
{
    FMDatabase *_db;
}

- (instancetype)init
{
    if (self = [super init]) {
        _db = [FMDatabase databaseWithPath:_groupChatsCacheFilePath];
    }
    return self;
}

- (BOOL)savaGroupChat:(NSString *)usr :(NSString *)chatId
{
    if (![_db open]) {
        return NO;
    }
    NSLog(@"%@", _groupChatsCacheFilePath);
    // 建表
    if (![_db executeUpdate:@"CREATE TABLE IF NOT EXISTS `t_groupchats` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `usrId` TEXT, groupchatId TEXT);"]) {
        return NO;
    }
    // 插入记录
    return [_db executeUpdate:@"INSERT INTO `t_groupchats`(`usrId`, `groupchatId`) VALUES(?, ?)", usr, chatId];
}

+ (instancetype)shareHelper
{
    if (_helper==nil) {
        _helper = [[GroupChatsHelper alloc] init];
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

@end