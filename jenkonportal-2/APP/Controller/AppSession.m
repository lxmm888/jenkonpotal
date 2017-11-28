//
//  AppSession.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "AppSession.h"
#import "DefaultPortraitView.h"

static AppSession *_session;

@implementation AppSession

#define _usrFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"usr.data"]

- (void)updateUsrToDB
{
    [NSKeyedArchiver archiveRootObject:_usr toFile:_usrFilePath];
}

- (UsrModel *)loadUsrFromDB
{
    _usr = [NSKeyedUnarchiver unarchiveObjectWithFile:_usrFilePath];
    return _usr;
}

+ (instancetype)shareSession
{
    if (_session==nil) {
        _session = [[AppSession alloc] init];
    }
    return _session;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _session = [super allocWithZone:zone];
    });
    return _session;

}

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath =
    [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    
    // NSString* path = [[[[NSBundle mainBundle] resourcePath]
    // stringByAppendingPathComponent:bundleName]stringByAppendingPathComponent:[NSString
    // stringWithFormat:@"%@.png",name]];
    
    // image = [UIImage imageWithContentsOfFile:image_path];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    return image;
}

+ (NSString *)getIconCachePath:(NSString *)fileName {
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(
                                                              NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =
    [cachPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"CachedIcons/%@",
      fileName]]; // 保存文件的名称
    
    NSString *dirPath = [cachPath
                         stringByAppendingPathComponent:[NSString
                                                         stringWithFormat:@"CachedIcons"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return filePath;
}

+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo {
    NSString *filePath = [[self class]
                          getIconCachePath:[NSString
                                            stringWithFormat:@"group%@.png", groupInfo.groupId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    } else {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:[NSString stringWithFormat:@"%@",groupInfo.groupId] 
                                 Nickname:groupInfo.groupName];
        UIImage *portrait = [defaultPortrait imageFromView];
        
        BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                           atomically:YES];
        if (result) {
            NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
            return [portraitPath absoluteString];
        } else {
            return nil;
        }
    }
}

+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo {
    NSString *filePath = [[self class]
                          getIconCachePath:[NSString
                                            stringWithFormat:@"user%@.png", userInfo.userId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    } else {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        
        BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                           atomically:YES];
        if (result) {
            NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
            return [portraitPath absoluteString];
        } else {
            return nil;
        }
    }
}


//字典转json格式字符串：
+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
