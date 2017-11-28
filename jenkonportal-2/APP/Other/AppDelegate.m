//
//  AppDelegate.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
// chenweidan 123456

#import "AppDelegate.h"
#import "APPTabBarContr.h"
#import "RootContrHelper.h"
#import "AppSession.h"
#import "LoginContr.h"
#import <RongIMKit/RongIMKit.h>
#import "RongIMKitHelper.h"
#import "AppConf.h"
#import "UIColor+WFColor.h"
#import "WFHttpTool.h"
#import "WFDataBaseManager.h"
#import "WFYAnnouncementMessage.h"
#import "RCDTestMessage.h"
#import "WFYCollectMessage.h"
//学习中。。。
#import "testViewController.h"
#import "tab.h"
// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <AdSupport/AdSupport.h>


@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[RCIM sharedRCIM] initWithAppKey:@"8luwapkv8rxil"];
//     
//    [[RCIMClient sharedRCIMClient] connectWithToken:@"aJufjGh6DVkjwjkJLbOmH0Y4QiuSwgAuMEkJzdqltUlL0qBFvTZYozJGGoa77WzthHjK5OAAlFdJQiwnJSsF4A==" success:^(NSString *userId) {
//        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
//    } error:^(RCConnectErrorCode status) {
//        
//    } tokenIncorrect:^{
//        
//    }];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[tab alloc] init]];
//    // Override point for customization after application launch.
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//
////    self.window.frame = [UIScreen mainScreen].bounds;
//    self.window.rootViewController = nav;
//
//    [self.window makeKeyAndVisible];
    
    
    
    // 融云初始化
    [[RCIM sharedRCIM] initWithAppKey:rongIMAppKey];
    
    // 注册自定义测试消息
    [[RCIM sharedRCIM] registerMessageType:[WFYAnnouncementMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[WFYCollectMessage class]];
    
    // 融云config
    // 头像圆型
    [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
    [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    //设置用户信息源和群组信息源 [RongIMKitHelper shareHelper]
    [RCIM sharedRCIM].userInfoDataSource =WFDataSource ;
    [RCIM sharedRCIM].groupInfoDataSource = WFDataSource;
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    //开启输入状态监听
    [RCIM sharedRCIM].enableTypingStatus = YES;
    //开启发送已读回执
    [RCIM sharedRCIM].enabledReadReceiptConversationTypeList = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION),@(ConversationType_GROUP)];
    //开启多端未读状态同步
    [RCIM sharedRCIM].enableSyncReadStatus = YES;
    //设置显示未注册的消息
    //如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
    [RCIM sharedRCIM].showUnkownMessage = YES;
    [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;
    
    //群成员数据源
    [RCIM sharedRCIM].groupMemberDataSource = WFDataSource;
    
    //开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
    [RCIM sharedRCIM].enableMessageMentioned = YES;
    
    //开启消息撤回功能
    [RCIM sharedRCIM].enableMessageRecall = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [RootContrHelper rootContr];
    
    //极光推送
    //1.添加初始化APNs代码
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    //2.添加初始化JPush代码
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:JPushAppKey
                          channel:JPushChannel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            NSLog(@"registrationID获取成功：%@",registrationID);
            //registrationID获取成功后，应该将其缓存在本地，程序登录成功后将其上传
            [[NSUserDefaults standardUserDefaults]
             setObject:registrationID
             forKey:@"WFYJPushRegistrationID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    //统一导航条样式
    UIFont *font = [UIFont systemFontOfSize:19.f];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     };
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:RGB(0, 90, 119)];//[UIColor colorWithHexString:@"0099ff" alpha:1.0f]
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1.5, 0)  forBarMetrics:UIBarMetricsDefault];
    UIImage *tmpImage = [UIImage imageNamed:@"back"];
    
    CGSize newSize = CGSizeMake(12, 20);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(2, -2, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    if (IOS_FSystenVersion >= 8.0) {
        [UINavigationBar appearance].translucent = NO;
    }
    
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:RCKitDispatchMessageNotification
     object:nil];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode ==
        RCSDKRunningMode_Background &&
        0 == left.integerValue) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                             @(ConversationType_PRIVATE),
                                                                             @(ConversationType_DISCUSSION),
                                                                             @(ConversationType_APPSERVICE),
                                                                             @(ConversationType_PUBLICSERVICE),
                                                                             @(ConversationType_GROUP),
                                                                             @(ConversationType_SYSTEM)
                                                                             ]];
        [UIApplication sharedApplication].applicationIconBadgeNumber =
        unreadMsgCount;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status != ConnectionStatus_SignUp) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient]
                              getUnreadCount:@[
                                               @(ConversationType_PRIVATE),
                                               @(ConversationType_DISCUSSION),
                                               @(ConversationType_APPSERVICE),
                                               @(ConversationType_PUBLICSERVICE),
                                               @(ConversationType_GROUP),
                                               @(ConversationType_SYSTEM)
                                               ]];
        application.applicationIconBadgeNumber = unreadMsgCount;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - RCIMConnectionStatusDelegate
/*!
 IMKit连接状态的的监听器
 
 @param status  SDK与融云服务器的连接状态
 
 @discussion 如果您设置了IMKit消息监听之后，当SDK与融云服务器的连接状态发生变化时，会回调此方法。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:
                              @"您的帐号在别的设备上登录，"
                              @"您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        //退出到登录窗口
        
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        //重新获取token并连接
        
    }else if (status == ConnectionStatus_DISCONN_EXCEPTION){
        [[RCIMClient sharedRCIMClient] disconnect];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:
                              @"您的帐号被封禁"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        //退出到登录窗口
        
    }
}

-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
                      withSenderName:(NSString *)senderName{
    //群组通知不弹本地通知
    if ([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
        return YES;
    }
    return NO;
}

//设置群组通知消息没有提示音
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message
{
    //当应用处于前台运行，收到消息不会有提示音。
    //  if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    return YES;
    //  }
    //  return NO;
}

#pragma mark - RCIMReceiveMessageDelegate
/*!
 接收消息的回调方法
 
 @param message     当前接收到的消息
 @param left        还剩余的未接收的消息数，left>=0
 
 @discussion 如果您设置了IMKit消息监听之后，SDK在接收到消息时候会执行此方法（无论App处于前台或者后台）。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if ([message.content
         isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg =
        (RCInformationNotificationMessage *)message.content;
        if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
            //接收到已成功添加好友的消息就从服务器同步好友列表
            //do sth
        }
    } else if ([message.content
                isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *msg =
        (RCContactNotificationMessage *)message.content;
        if ([msg.operation
             isEqualToString:
             ContactNotificationMessage_ContactOperationAcceptResponse]) {
            //接收到别人请求添加好友的请求，如果同意就从服务器同步好友列表
            //do sth
        }
    } else if ([message.content
                isMemberOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *msg =
        (RCGroupNotificationMessage *)message.content;
        NSString * groupIdStr = [NSString stringWithFormat:@"%@",message.targetId];
        if ([msg.operation isEqualToString:@"Dismiss"] &&
            [msg.operatorUserId
             isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP
                                                    targetId:groupIdStr];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP
                                                         targetId:groupIdStr];
            } else if ([msg.operation isEqualToString:@"Quit"]   ||
                       [msg.operation isEqualToString:@"Add"]    ||
                       [msg.operation isEqualToString:@"Kicked"] ||
                       [msg.operation isEqualToString:@"Rename"]) {
                if (![msg.operation isEqualToString:@"Rename"]) {
                    //根据groupId获取群组成员信息
                    [WFHTTPTOOL getGroupMembersWithGroupId:groupIdStr
                                                     Block:^(NSMutableArray *result) {
                                                         [[WFDataBaseManager shareInstance]
                                                          insertGroupMemberToDB:result
                                                          groupId:groupIdStr
                                                          complete:^(BOOL results) {
                                                              //
                                                          }];
                                                     }];
                }
                //根据id获取单个群组
                [WFHTTPTOOL getGroupByID:groupIdStr
                       successCompletion:^(WFGroupInfo *group) {
                           [[WFDataBaseManager shareInstance] insertGroupToDB:group];
                           [[RCIM sharedRCIM] refreshGroupInfoCache:group
                                                        withGroupId:groupIdStr];
                           [[NSNotificationCenter defaultCenter]
                            postNotificationName:@"UpdeteGroupInfo"
                            object:groupIdStr];
                       }];
            }
    }
}

/**
 *注册APNs成功并上报DeviceToken
 */
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

/**
 * 实现注册APNs失败接口（可选）
 */
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    XILog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    [self handleRemoteNotification:userInfo];
    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
//        [rootViewController addNotificationCount];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate

-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(NSInteger))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request;//收到推送的请求
    UNNotificationContent *content = request.content;     //收到推送的消息内容
    
    NSNumber *badge = content.badge; // 推送消息的角标
    NSString *body = content.body;   // 推送消息体
    UNNotificationSound *sound = content.sound; //推送消息的声音
    NSString *subtitle = content.subtitle; //推送消息的副标题
    NSString *title = content.title; // 推送消息的标题
    //判断为本地通知还是远程通知
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        XILog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
    }
    else{
        //判断为本地通知
        XILog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
    
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}

#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
//    [NSPropertyListSerialization propertyListFromData:tempData
//                                     mutabilityOption:NSPropertyListImmutable
//                                               format:NULL
//                                     errorDescription:NULL];
    [NSPropertyListSerialization propertyListWithData:tempData
                                              options:NSPropertyListImmutable
                                               format:NULL
                                                error:NULL];
    return str;
}

/*
 * 对极光推送的通知进行处理
 {
     "_j_business" = 1;
     "_j_msgid" = 51791396529807356;
     "_j_uid" = 11069646263;
     aps =     {
         alert = "27|沟通技巧";
         };
 }
 */

- (void)handleRemoteNotification:(NSDictionary *)remoteInfoDic{
    if (![remoteInfoDic count]) {
        return;
    }
    NSString * apsAlert= remoteInfoDic[@"aps"][@"alert"];
    NSArray *arr = [apsAlert componentsSeparatedByString:@"|"];
    NSString *announcementId = [arr objectAtIndex:0];
    [WFHTTPTOOL sendAnncMsgWithUserId:kUserId
                       AnnouncementId:announcementId
                             complete:^(BOOL isOK) {
                                 if (isOK) {
                                     NSLog(@"公告消息发送成功");
                                 }
                                 else{
                                     NSLog(@"公告消息发送失败");
                                 }
                             }];
}

@end
