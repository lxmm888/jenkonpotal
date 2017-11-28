//
//  WFDataBaseManager.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/21.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFDataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "UsrModel.h"
#import "WFGroupInfo.h"
#import "AppSession.h"
#import "WFYAnnouncementModel.h"
#import "WFYHomePortalItem.h"
#import "WFYCollectionModel.h"

@interface WFDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation WFDataBaseManager

static NSString *const userTableName = @"USERTABLE";
static NSString *const groupTableName = @"GROUPCHATTABLE";
static NSString *const friendTableName = @"FRIENDSTABLE";
static NSString *const blackTableName = @"BLACKTABLE";
static NSString *const groupMemberTableName = @"GROUPMEMBERTABLE";
static NSString *const announcementTableName = @"ANNOUNCEMENTTABLE";
static NSString *const portalItemTableName = @"PORTALITEMTABLE";
static NSString *const collectionTableName = @"COLLECTIONTABLE";


+ (WFDataBaseManager *)shareInstance {
    static WFDataBaseManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        [instance dbQueue];
    });
    return instance;
}

- (FMDatabaseQueue *)dbQueue {
    if ([RCIMClient sharedRCIMClient].currentUserInfo.userId == nil) {
        return nil;
    }
    
    if (!_dbQueue) {
        [self moveDBFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask, YES);
        NSString *const wiseFly = @"WiseFly";
        NSString *library = [[paths objectAtIndex:0] stringByAppendingPathComponent:wiseFly];
        if (![[NSFileManager defaultManager] fileExistsAtPath:library]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:library withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *dbPath = [library
                            stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"WiseFlyPortalDB%@",
                             [RCIMClient sharedRCIMClient]
                             .currentUserInfo.userId]];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        if (_dbQueue) {
            [self createUserTableIfNeed];
        }
    }
    return _dbQueue;
}

- (void)moveFile:(NSString*)fileName fromPath:(NSString*)fromPath toPath:(NSString*)toPath{
    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* srcPath = [fromPath stringByAppendingPathComponent:fileName];
    NSString* dstPath = [toPath stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:nil];
}


/**
 苹果审核时，要求打开itunes sharing功能的app在Document目录下不能放置用户处理不了的文件
 2.8.9之前的版本数据库保存在Document目录
 从2.8.9之前的版本升级的时候需要把数据库从Document目录移动到Library/Application Support目录
 */
- (void)moveDBFile {
    NSString *const wiseFlyPortalDBString = @"WiseFlyPortalDB";
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"WiseFly"];
    NSArray<NSString*> *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
    [subPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:wiseFlyPortalDBString]) {
            [self moveFile:obj fromPath:documentPath toPath:libraryPath];
        }
    }];
}

//创建用户存储表
- (void)createUserTableIfNeed {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isTableOK:userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupTableName withDB:db]) {
            NSString *createTableSQL =
            @"CREATE TABLE GROUPCHATTABLE (id integer PRIMARY KEY autoincrement, "
            @"groupId text,name text, portraitUri text,inNumber text,maxNumber "
            @"text ,introduce text ,creatorId text,creatorTime text, isJoin "
            @"text, isDismiss text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_groupid ON GROUPCHATTABLE(groupId);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDSTABLE (id integer "
            @"PRIMARY KEY autoincrement, userid "
            @"text,name text, portraitUri text, status "
            @"text, updatedAt text, displayName text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_friendsId ON FRIENDSTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        } else if (![self isColumnExist:@"displayName" inTable:friendTableName withDB:db]) {
            [db executeUpdate:@"ALTER TABLE FRIENDSTABLE ADD COLUMN displayName text"];
        }
        
        if (![self isTableOK:blackTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE BLACKTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_blackId ON BLACKTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupMemberTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPMEMBERTABLE (id integer "
            @"PRIMARY KEY autoincrement, groupid text, "
            @"userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_groupmemberId ON "
            @"GROUPMEMBERTABLE(groupid,userid);";
            [db executeUpdate:createIndexSQL];
        }
        
//        NSString *dropTableSQL = @"DROP TABLE ANNOUNCEMENTTABLE";
//        [db executeUpdate:dropTableSQL];
        
        if (![self isTableOK:announcementTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE ANNOUNCEMENTTABLE (id integer "
            @"PRIMARY KEY autoincrement,announcementId text, "
            @"anncTopic text,anncPublisher text,timeStamp text,anncSummary text,anncPicURL text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_announcementId ON "
            @"ANNOUNCEMENTTABLE(announcementId)";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:collectionTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE COLLECTIONTABLE (id integer "
            @"PRIMARY KEY autoincrement,collectionId text,collectionSourceType text,collectionSourceName text, "
            @"collectionSourceId text,timeStamp text,collectionPicURL text,collectionTitle text,collectionDesc text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_cellectionId ON "
            @"COLLECTIONTABLE(id)";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:portalItemTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE PORTALITEMTABLE (id integer "
            @"PRIMARY KEY autoincrement, name text, "
            @"icon text,url text,type text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_portalitemId ON "
            @"PORTALITEMTABLE(name,icon);";
            [db executeUpdate:createIndexSQL];
        }
    }];
}

- (BOOL)isTableOK:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isOK = NO;
    
    FMResultSet *rs =
    [db executeQuery:@"select count(*) as 'count' from sqlite_master where "
     @"type ='table' and name = ?",
     tableName];
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count) {
            isOK = NO;
        } else {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

- (BOOL)isColumnExist:(NSString *)columnName inTable:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isExist = NO;
    
    NSString *columnQurerySql = [NSString stringWithFormat:@"SELECT %@ from %@", columnName, tableName];
    FMResultSet *rs = [db executeQuery:columnQurerySql];
    if ([rs next]) {
        isExist = YES;
    } else {
        isExist = NO;
    }
    [rs close];
    
    return isExist;
}

#pragma mark 用户

//存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user {
    NSString *insertSql =
    @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, user.userId, user.name, user.portraitUri];
    }];
}

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId {
    __block RCUserInfo *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?", userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

#pragma mark 群

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB {
    __block BOOL result = NO;
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM GROUPCHATTABLE"];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:clearSql];
    }];
    return result;
}

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId {
    if ([groupId length] < 1)
        return;
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",
     @"GROUPCHATTABLE", @"groupid", groupId];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//存储群组信息
- (void)insertGroupToDB:(WFGroupInfo *)group {
    if (group == nil || [[NSString stringWithFormat:@"%@",group.groupId] length] < 1)
        return;
    
    NSString *insertSql = @"REPLACE INTO GROUPCHATTABLE (groupId, "
    @"name,portraitUri,inNumber,maxNumber,introduce,"
    @"creatorId,creatorTime,isJoin,isDismiss) VALUES "
    @"(?,?,?,?,?,?,?,?,?,?)";
    
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, group.groupId, group.groupName,
         group.portraitUri, group.number, group.maxNumber,
         group.introduce, group.creatorId, group.creatorTime,
         [NSString stringWithFormat:@"%d", group.isJoin],
         group.isDismiss];
    }];
}

- (void)insertGroupsToDB:(NSMutableArray *)groupList complete:(void (^)(BOOL))result{
    
    if (groupList == nil || [groupList count] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (WFGroupInfo *group in groupList) {
                NSString *insertSql = @"REPLACE INTO GROUPCHATTABLE (groupId, "
                @"name,portraitUri,inNumber,maxNumber,introduce,"
                @"creatorId,creatorTime,isJoin,isDismiss) VALUES "
                @"(?,?,?,?,?,?,?,?,?,?)";
                [db executeUpdate:insertSql, group.groupId, group.groupName,
                 group.portraitUri, group.number, group.maxNumber,
                 group.introduce, group.creatorId, group.creatorTime,
                 [NSString stringWithFormat:@"%d", group.isJoin],
                 group.isDismiss];
            }
        }];
        result (YES);
    });
}

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup {
    NSMutableArray *allGroups = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM GROUPCHATTABLE"];
        while ([rs next]) {
            WFGroupInfo *model;
            model = [[WFGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number = [rs stringForColumn:@"inNumber"];
            model.maxNumber = [rs stringForColumn:@"maxNumber"];
            model.introduce = [rs stringForColumn:@"introduce"];
            model.creatorId = [rs stringForColumn:@"creatorId"];
            model.creatorTime = [rs stringForColumn:@"creatorTime"];
            model.isJoin = [rs boolForColumn:@"isJoin"];
            [allGroups addObject:model];
        }
        [rs close];
    }];
    return allGroups;
}

//从表中获取群组信息
- (WFGroupInfo *)getGroupByGroupId:(NSString *)groupId {
    __block WFGroupInfo *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db
                           executeQuery:@"SELECT * FROM GROUPCHATTABLE where groupId = ?", groupId];
        while ([rs next]) {
            model = [[WFGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number = [rs stringForColumn:@"inNumber"];
            model.maxNumber = [rs stringForColumn:@"maxNumber"];
            model.introduce = [rs stringForColumn:@"introduce"];
            model.creatorId = [rs stringForColumn:@"creatorId"];
            model.creatorTime = [rs stringForColumn:@"creatorTime"];
            model.isJoin = [rs boolForColumn:@"isJoin"];
            model.isDismiss = [rs stringForColumn:@"isDismiss"];
        }
        [rs close];
    }];
    return model;
}

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result
{
    if (groupMemberList == nil || [groupMemberList count] < 1)
        return;
    
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",
     @"GROUPMEMBERTABLE", @"groupid", groupId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:deleteSql];
            for (RCUserInfo *user in groupMemberList) {
                NSString *insertSql = @"REPLACE INTO GROUPMEMBERTABLE (groupid, userid, "
                @"name, portraitUri) VALUES (?, ?, ?, ?)";
                if (user.portraitUri.length <= 0) {
                    user.portraitUri = [AppSession defaultUserPortrait:user];
                }
                [db executeUpdate:insertSql, groupId, user.userId, user.name,
                 user.portraitUri];
            }
        }];
        result (YES);
    });
}

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:
         @"SELECT * FROM GROUPMEMBERTABLE where groupid=? order by id",
         groupId];
        while ([rs next]) {
            //            RCUserInfo *model;
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

#pragma mark  发布公告
//存储公告
- (void)insertAnnouncementToDB:(WFYAnnouncementModel *)announcement;{
    NSString *anncId_str = announcement.announcementId;
    if (anncId_str == nil || [anncId_str length] < 1)
        return;
    NSString *insertSql = @"REPLACE INTO ANNOUNCEMENTTABLE (announcementId, "
    @"anncTopic,anncPublisher,timeStamp,anncSummary,anncPicURL) VALUES "
    @"(?, ?, ?, ?, ?, ?)";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,anncId_str,announcement.anncTopic,
         announcement.anncPublisher,announcement.timeStamp,
         announcement.anncSummary,announcement.anncPicURL];
    }];
}


- (void)insertAnnouncementToDB:(NSMutableArray *)announcementList
                      complete:(void (^)(BOOL))result{
    if (announcementList == nil || [announcementList count] < 1)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (WFYAnnouncementModel *announcement in announcementList) {
                NSString *anncId_str = announcement.announcementId;
                if (anncId_str == nil || [anncId_str length] < 1)
                    return;
                NSString *insertSql = @"REPLACE INTO ANNOUNCEMENTTABLE (announcementId, "
                @"anncTopic,anncPublisher,timeStamp,anncSummary,anncPicURL) VALUES "
                @"(?, ?, ?, ?, ?, ?)";
                [db executeUpdate:insertSql,anncId_str,announcement.anncTopic,
                 announcement.anncPublisher,announcement.timeStamp,announcement.anncSummary,
                 announcement.anncPicURL];
            }
        }];
        result(YES);
    });
}

//删除公告
- (void)deleteAnnouncementToDB:(NSString *)announcementId{
    if ([announcementId length] <1)
        return;
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",
                           @"ANNOUNCEMENTTABLE",@"announcementId",announcementId];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//从表中获取全部公告
- (NSArray *)getAllAnnouncement{
    NSMutableArray *allAnnouncements = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM ANNOUNCEMENTTABLE "];
        while ([rs next]) {
            WFYAnnouncementModel *model;
            model = [[WFYAnnouncementModel alloc] init];
            model.announcementId = [rs stringForColumn:@"announcementId"];
            model.anncTopic = [rs stringForColumn:@"anncTopic"];
            model.anncPublisher = [rs stringForColumn:@"anncPublisher"];
            model.timeStamp = [rs stringForColumn:@"timeStamp"];
            model.anncSummary = [rs stringForColumn:@"anncSummary"];
            model.anncPicURL = [rs stringForColumn:@"anncPicURL"];
            [allAnnouncements addObject:model];
        }
        [rs close];
    }];
    return allAnnouncements;
}

//从表中获取公告信息
- (WFYAnnouncementModel *)getAnnouncementByID:(NSString *)announcementId{
    __block WFYAnnouncementModel *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db
                           executeQuery:@"SELECT * FROM ANNOUNCEMENTTABLE where announcementId = ?", announcementId];
        while ([rs next]) {
            model = [[WFYAnnouncementModel alloc] init];
            model.announcementId = [rs stringForColumn:@"announcementId"];
            model.anncTopic = [rs stringForColumn:@"anncTopic"];
            model.anncPublisher = [rs stringForColumn:@"anncPublisher"];
            model.timeStamp = [rs stringForColumn:@"timeStamp"];
            model.anncSummary = [rs stringForColumn:@"anncSummary"];
            model.anncPicURL = [rs stringForColumn:@"anncPicURL"];
        }
        [rs close];
    }];
    return model;
}

#pragma mark 收藏
- (BOOL)clearCollectionfromDB{
    __block BOOL result = NO;
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM COLLECTIONTABLE"];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:clearSql];
    }];
    return result;
}

- (void)insertCollectionToDB:(WFYCollectionModel *)collection{
    NSString *collectionId = [NSString stringWithFormat:@"%@",collection.collectionId];
    if (collectionId == nil || collectionId.length < 1)
        return;
    NSString *insertSql = @"REPLACE INTO COLLECTIONTABLE (collectionId,collectionSourceType, "
    @"collectionSourceName,collectionSourceId,timeStamp,collectionPicURL,collectionTitle,collectionDesc) VALUES "
    @"(?, ?, ?, ?, ?, ?, ?, ?)";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,collectionId,collection.collectionSourceType,
         collection.collectionSourceName,collection.collectionSourceId,collection.timeStamp,
         collection.collectionPicURL,collection.collectionTitle,collection.collectionDesc];
    }];
}

- (void)insertCollectionsToDB:(NSMutableArray *)collectionList
                     complete:(void (^)(BOOL))result{
    if (collectionList == nil || [collectionList count] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (WFYCollectionModel *collection in collectionList) {
                NSString *insertSql = @"REPLACE INTO COLLECTIONTABLE (collectionId,collectionSourceType, "
                @"collectionSourceName,collectionSourceId,timeStamp,collectionPicURL,collectionTitle,collectionDesc) VALUES "
                @"(?, ?, ?, ?, ?, ?, ?, ?)";
                [db executeUpdate:insertSql,collection.collectionId,collection.collectionSourceType,
                 collection.collectionSourceName,collection.collectionSourceId,collection.timeStamp,
                 collection.collectionPicURL,collection.collectionTitle,collection.collectionDesc];
            }
        }];
        result (YES);
    });
}

//获取全部收藏
- (NSMutableArray *)getAllCollection{
    NSMutableArray *allCollections = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM COLLECTIONTABLE "];
        while ([rs next]) {
            WFYCollectionModel *model;
            model = [[WFYCollectionModel alloc] init];
            model.collectionId = [rs stringForColumn:@"collectionId"];
            model.collectionSourceType = [rs stringForColumn:@"collectionSourceType"];
            model.collectionSourceId = [rs stringForColumn:@"collectionSourceId"];
            model.collectionSourceName = [rs stringForColumn:@"collectionSourceName"];
            model.timeStamp = [rs stringForColumn:@"timeStamp"];
            model.collectionPicURL = [rs stringForColumn:@"collectionPicURL"];
            model.collectionTitle = [rs stringForColumn:@"collectionTitle"];
            model.collectionDesc = [rs stringForColumn:@"collectionDesc"];
            [allCollections addObject:model];
        }
        [rs close];
    }];
//    WFYCollectionModel *model;
//    model = [[WFYCollectionModel alloc] init];
//    model.collectionType = @"公告";
//    model.collectionId = @"43";
//    model.collectionSource = @"公告";
//    model.timeStamp =  @"1510194273";
//    model.collectionPicURL = @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3961249540,4158281452&fm=27&gp=0.jpg";
//    model.collectionTitle = @"苏格兰风景";
//    model.collectionDesc = @"苏格兰风笛";
//    [allCollections addObject:model];
//
//    WFYCollectionModel *model3;
//    model3 = [[WFYCollectionModel alloc] init];
//    model3.collectionType = @"公告";
//    model3.collectionId = @"43";
//    model3.collectionSource = @"公告";
//    model3.timeStamp =  @"1510194273";
//    //model3.collectionPicURL = @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3961249540,4158281452&fm=27&gp=0.jpg";
//    model3.collectionTitle = @"苏格兰风景";
//    model3.collectionDesc = @"苏格兰风笛";
//    [allCollections addObject:model3];
//
//    WFYCollectionModel *model2;
//    model2 = [[WFYCollectionModel alloc] init];
//    model2.collectionType = @"公告";
//    model2.collectionId = @"43";
//    model2.collectionSource = @"公告";
//    model2.timeStamp =  @"1510194273";
//    model2.collectionPicURL = @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3961249540,4158281452&fm=27&gp=0.jpg";
//    model2.collectionTitle = @"苏格兰风景";
//    model2.collectionDesc = @"苏格兰风笛";
//    [allCollections addObject:model2];
    
    return allCollections;
}

- (WFYCollectionModel *)getCollectionByCollectionId:(NSString *)collectionId{
    __block WFYCollectionModel *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db
                           executeQuery:@"SELECT * FROM COLLECTIONTABLE where collectionId = ?", collectionId];
        while ([rs next]) {
            model = [[WFYCollectionModel alloc] init];
            model.collectionId = [rs stringForColumn:@"collectionId"];
            model.collectionSourceType = [rs stringForColumn:@"collectionSourceType"];
            model.collectionSourceName = [rs stringForColumn:@"collectionSourceName"];
            model.collectionSourceId = [rs stringForColumn:@"collectionSourceId"];
            model.timeStamp = [rs stringForColumn:@"timeStamp"];
            model.collectionPicURL = [rs stringForColumn:@"collectionPicURL"];
            model.collectionTitle = [rs stringForColumn:@"collectionTitle"];
            model.collectionDesc = [rs stringForColumn:@"collectionDesc"];
        }
        [rs close];
    }];
    return model;
}

#pragma mark 工作台门户

- (NSMutableArray *)getHomePortalItem{
    NSMutableArray *portalItems = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:
         @"SELECT * FROM PORTALITEMTABLE order by id"];
        while ([rs next]) {
            WFYHomePortalItem *model;
            model = [[WFYHomePortalItem alloc] init];
            model.Name = [rs stringForColumn:@"name"];
            model.Icon = [rs stringForColumn:@"icon"];
            model.URL = [rs stringForColumn:@"url"];
            model.Type = [rs stringForColumn:@"type"];
            [portalItems addObject:model];
        }
        [rs close];
    }];
    return portalItems;
}

//存储首页的门户内容
- (void)insertHomePortalItemToDB:(NSMutableArray *)portalItemList
                        complete:(void (^)(BOOL))result{
//    if (portalItemList == nil || [portalItemList count] < 1)
//        return;
    //添加【更多】按钮
    WFYHomePortalItem *item = [[WFYHomePortalItem alloc] init];
    item.Name = @"更多";
    item.Icon = @"home_cell_more";
    [portalItemList addObject:item];
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ ",@"PORTALITEMTABLE"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:deleteSql];
            for (WFYHomePortalItem *item in portalItemList) {
                NSString *insertSql = @"REPLACE INTO PORTALITEMTABLE (name, icon, "
                @"url,type) VALUES (?, ?, ?, ?)";
                [db executeUpdate:insertSql, item.Name, item.Icon, item.URL,item.Type];
            }
        }];
        result (YES);
    });
}
@end
