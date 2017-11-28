//
//  ChatsContr.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/10.
//  Copyright © 2017年 com.xia. All rights reserved.
//


#import "ChatsContr.h"
#import "MJRefresh.h"
#import "XICommonDef.h"
#import "ChatContr.h"
#import "APPTabBarContr.h"
#import "WFUIBarButtonItem.h"
#import "KxMenu.h"  //UI高度可定制化弹出菜单第三方自定义类
#import "AppConf.h"
#import "WFSearchFriendViewController.h"
#import "ZuZhiJiaGouContr.h"
#import "WFContactSelectedContr.h"
#import "GroupChatsContr.h"
#import <RongIMKit/RongIMKit.h>
#import "UsrInfoApi.h"
#import "APPWebMgr.h"
#import "SVProgressHUD.h"
#import "UsrModel.h"
#import "WFYChatsAnncCell.h"
#import "UIImageView+WebCache.h"
#import "WFYAnnouncementContr.h"
#import "WFYAnnouncementMessage.h"
#import "WFHttpTool.h"
#import "WFDataBaseManager.h"
#import "WFYAnnouncementModel.h"

@interface ChatsContr ()

@property(nonatomic, assign) BOOL isClick;//是否第一次点击

@end

@implementation ChatsContr
{
    UsrInfoApi *_usrInfoApi;
    APPWebMgr *_webMgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:ConversationType_PRIVATE targetId:@"11" recordTime:0 count:20 success:^(NSArray *messages) {
//        NSLog(@"%@",)
//    } error:^(RCErrorCode status) {
//        
//    }];
    [RCImageMessage messageWithImage:[UIImage new]];
    NSArray *conversationArr = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_GROUP),@(ConversationType_SYSTEM),@(ConversationType_PRIVATE)]];
    
    NSLog(@"%@",conversationArr);
    
    [self initIvar];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rebindUIValue];
}

- (void) initIvar{
    _usrInfoApi = [[UsrInfoApi alloc]init];
}

- (void)initUI
{
    //自定义rightBarButtonItem
    [self bindRightItem];
    [self bindUIValue];
}

//自定义rightBarButtonItem
- (void)bindRightItem
{
    WFUIBarButtonItem *rightBtn=
    [[WFUIBarButtonItem alloc]initContainImage:[UIImage imageNamed:@"add"]
                               imageViewFrame:CGRectMake(0, 0, 17, 17)//0->8
                                  buttonTitle:nil
                                   titleColor:nil
                                   titleFrame:CGRectZero
                                  buttonFrame:CGRectMake(0, 0, 17, 17)
                                       target:self
                                        action:@selector(showMenu:)];
    self.navigationItem.rightBarButtonItems = [rightBtn setTranslation:rightBtn translation:-6];
}

- (void)bindUIValue
{
    self.conversationListTableView.tableFooterView = [[UIView alloc] init];
    
    // 设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM),
                                        @(ConversationType_PUSHSERVICE)]];
    
    // 设置需要将哪些类型的会话在会话列表中聚合显示
    // 聚合显示指的是此类型所有会话，在会话列表中聚合显示成一条消息，点击进去会显示此类型的具体会话列表
    /*@(ConversationType_DISCUSSION),
     @(ConversationType_GROUP)*/
    //[self setCollectionConversationType:@[ @(ConversationType_SYSTEM)]];
}


/**
 *  右上角弹出菜单
 */
- (void)showMenu:(UIButton *)sender {
    NSArray *menuItems = @[
                           
                           [KxMenuItem menuItem:@"发起聊天"
                                          image:[UIImage imageNamed:@"startchat_icon"]
                                         target:self
                                         action:@selector(pushChat:)],
                           [KxMenuItem menuItem:@"发起群聊"
                                          image:[UIImage imageNamed:@"addfriend_icon"]
                                         target:self
                                         action:@selector(pushGroupChat:)],
                           [KxMenuItem menuItem:@"创建群组"
                                          image:[UIImage imageNamed:@"creategroup_icon"]
                                         target:self
                                         action:@selector(pushCreateGroupChat:)],
                           [KxMenuItem menuItem:@"通知公告"
                                          image:[UIImage imageNamed:@"addfriend_icon"]
                                         target:self
                                         action:@selector(pushAddFriend:)],
                           ];
    UIBarButtonItem *rightBarButton =self.navigationItem.rightBarButtonItems[1];
    CGRect targetFrame = rightBarButton.customView.frame;
    targetFrame.origin.y = targetFrame.origin.y + 15;
    [KxMenu setTintColor:HEXCOLOR(0x000000)];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:
     //self.tabBarController.navigationController.navigationBar.superview
     self.navigationController.navigationBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}

/**
 * 发起聊天
 * 点击【发起聊天】，就类似点击【通讯录】-【组织架构】按钮一样，弹出组织架构成员列表，能够选择单个成员进行会话
 */
- (void)pushChat:(id)sender{
    WFContactSelectedContr *contactSelectedVC = [[WFContactSelectedContr alloc] init];
    contactSelectedVC.isAllowsMultipleSelection = NO;
    contactSelectedVC.titleStr = @"发起聊天";
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

/**
 *  创建群组
 */
- (void)pushCreateGroupChat:(id)sender{
    WFContactSelectedContr *contactSelectedVC = [[WFContactSelectedContr alloc] init];
    contactSelectedVC.forCreatingGroup = YES;
    contactSelectedVC.isAllowsMultipleSelection = YES;
    contactSelectedVC.titleStr = @"选择联系人";
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

/**
 *  添加好友
 */
- (void)pushAddFriend:(id)sender{
//WFSearchFriendViewController * searchFriendVC =[WFSearchFriendViewController searchFriendViewController];
//    [self.navigationController pushViewController:searchFriendVC animated:YES];
    WFYAnnouncementContr *announcementVC = [[WFYAnnouncementContr alloc]init];
    [self.navigationController pushViewController:announcementVC animated:YES];
}


/**
 *  发起群聊
 */
- (void)pushGroupChat:(id)sender{
    [self.navigationController pushViewController:[[GroupChatsContr alloc] init] animated:YES];
}



// override
- (void)notifyUpdateUnreadMessageCount
{
    NSInteger count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                      @(ConversationType_PRIVATE),
                                                                      @(ConversationType_DISCUSSION),
                                                                      @(ConversationType_APPSERVICE),
                                                                      @(ConversationType_PUBLICSERVICE),
                                                                      @(ConversationType_GROUP)
                                                                      ]];
    NSString *title = nil;
    if (count>0&&count<10000) {
        title = [NSString stringWithFormat:@"消息(%ld)", (long)count];
    }else {
        title = @"消息";
    }
    
    BOOL hideRedPoint = YES;
    if (count>0) {
        hideRedPoint ^= 1;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = title;
        
        [(APPTabBarContr *)self.navigationController.tabBarController hideRedPoint:hideRedPoint :0];
    });
}

- (void)rebindUIValue
{   _isClick = YES;
    [self notifyUpdateUnreadMessageCount];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//重写RCConversationListViewController的onSelectedTableRow事件,点击进入聊天会话界面
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
//    ChatContr *conversationVC = [[ChatContr alloc]init];
//    conversationVC.conversationType = model.conversationType;
//    conversationVC.targetId = model.targetId;
//    conversationVC.title = model.conversationTitle;//想显示的会话标题
//    [self.navigationController pushViewController:conversationVC animated:YES];
    if (_isClick) {
        _isClick = NO;
        if (model.conversationModelType ==
            RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
            ChatContr *_conversationVC =
            [[ChatContr alloc] init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.title = model.conversationTitle;//想显示的会话标题
            _conversationVC.conversation = model;
            [self.navigationController pushViewController:_conversationVC
                                                 animated:YES];
        }
        
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            ChatContr *_conversationVC =
            [[ChatContr alloc] init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
            _conversationVC.enableUnreadMessageIcon = YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                _conversationVC.title = @"系统消息";
            }
            //收到公告的通知消息
            if ([model.objectName isEqualToString:WFYAnnouncementMessageTypeIdentifier]) {
                WFYAnnouncementContr *announcementVC = [[WFYAnnouncementContr alloc]init];
                [self.navigationController pushViewController:announcementVC animated:YES];
                return;
            }
            //如果是单聊，不显示发送方昵称
            if (model.conversationType == ConversationType_PRIVATE) {
                _conversationVC.displayUserNameInCell = NO;
            }
            [self.navigationController pushViewController:_conversationVC
                                                 animated:YES];
        }
        
        //聚合会话类型
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
            
            ChatsContr *temp =
            [[ChatsContr alloc] init];
            NSArray *array = [NSArray
                              arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
            [temp setDisplayConversationTypes:array];
            [temp setCollectionConversationType:nil];
            temp.isEnteredToCollectionViewController = YES;
            [self.navigationController pushViewController:temp animated:YES];
        }
        
        //自定义会话类型
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
            RCConversationModel *model =
            self.conversationListDataSource[indexPath.row];
            //收到公告的通知消息
            if ([model.objectName isEqualToString:WFYAnnouncementMessageTypeIdentifier]) {
                WFYAnnouncementContr *announcementVC = [[WFYAnnouncementContr alloc]init];
                [self.navigationController pushViewController:announcementVC animated:YES];
            }
        }
    }
    //从数据库中重新读取会话列表数据，并刷新会话列表
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [self refreshConversationTableViewIfNeeded];
                   });
}


#pragma mark overload

//*********************插入自定义Cell*********************//

/*
 1、可以对所有会话类型自定义 cell
 
 2、继承会话列表界面 RCConversationListViewController；
 
 3、重写方法
 
 -(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
 
 注：在该方法内筛选数据源dataSource中具体的会话类型及消息的model，将model 类型必须修改为 model.conversationModelType=RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION
 
 4、重写返回 cell 高度的方法
 
 // 高度
 -(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 // 自定义cell
 -(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 5、重写收到消息处理,在方法里生成新的 model，插入会话列表数据源 conversationListDataSource，更新页面，生成的  model 类型 conversationModelType 必须是 RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION
 #pragma mark - 收到消息监听
 -(void)didReceiveMessageNotification:(NSNotification *)notification
 
 参考 demo 会话列表的 RCDChatListViewController 中上述相关方法实现和自定义Cell（RCDChatListCell）, demo 具体是针对系统会话（ ConversationType_SYSTEM ）的好友请求消息（ RCContactNotificationMessage ）做了自定义 Cell
 */

//插入自定义会话model
/**
 *在该方法内筛选数据源dataSource中具体的会话类型及消息的model，将model 类型必须修改为 model.conversationModelType=RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION
 */
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource{
    for (int i=0; i<dataSource.count; i++) {
        RCConversationModel *model = dataSource[i];
        //筛选系统消息，用于生成自定义会话类型的cell
        if (model.conversationType == ConversationType_SYSTEM &&
           [model.lastestMessage isMemberOfClass:[WFYAnnouncementMessage class]]
            ) {
            //用户自定义的会话显示
            model.conversationModelType= RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        }
        
        if ([model.lastestMessage
             isKindOfClass:[RCGroupNotificationMessage class]]) {
            RCGroupNotificationMessage *groupNotification =
            (RCGroupNotificationMessage *)model.lastestMessage;
            if ([groupNotification.operation isEqualToString:@"Quit"]) {
                NSData *jsonData =
                [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization
                                            JSONObjectWithData:jsonData
                                            options:NSJSONReadingMutableContainers
                                            error:nil];
                NSDictionary *data =
                [dictionary[@"data"] isKindOfClass:[NSDictionary class]]
                ? dictionary[@"data"]
                : nil;
                NSString *nickName =
                [data[@"operatorNickname"] isKindOfClass:[NSString class]]
                ? data[@"operatorNickname"]
                : nil;
                if ([nickName isEqualToString:[RCIM sharedRCIM].currentUserInfo.name]) {
                    [[RCIMClient sharedRCIMClient]
                     removeConversation:model.conversationType
                     targetId:model.targetId];
                    [self refreshConversationTableViewIfNeeded];
                }
            }
        }
        
    }
    return dataSource;
}

/**
 *左滑删除
 */
- (void)rcConversationListTableView:(UITableView *)tableView
                 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                  forRowAtIndexPath:(NSIndexPath *)indexPath{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM
                                            targetId:model.targetId];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [self.conversationListTableView reloadData];
}
 
 
/**
 *重写返回 cell 高度的方法
 */
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67.0f;
}

/**
 *自定义cell
 */
-(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
//    if (model.conversationType == ConversationType_PUSHSERVICE &&
//        [model.lastestMessage isMemberOfClass:[WFYAnnouncementMessage class]]) {
//        //
//    }
    __block NSString *userName = nil;
    WFYAnnouncementMessage *_anncMsg = nil;
    _anncMsg =(WFYAnnouncementMessage *)model.lastestMessage;
    __weak ChatsContr *weakSelf = self;
    
    if (nil == model.extend) {
        NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]
                                         objectForKey:_anncMsg.anncPublisher];
        if (_cache_userinfo) {
            userName = _cache_userinfo[@"username"];
        } else {
            NSDictionary *emptyDic = @{};
            [[NSUserDefaults standardUserDefaults]
             setObject:emptyDic
             forKey:_anncMsg.anncPublisher];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [WFHTTPTOOL getUserInfoByUserID:_anncMsg.anncPublisher completion:^(RCUserInfo *user) {
                if (user == nil) {
                    return;
                }
                model.extend = user.name;
                // local cache for userInfo
                NSDictionary *userinfoDic = @{
                                              @"username" : user.name,
                                              @"portraitUri" : user.portraitUri
                                              };
                [[NSUserDefaults standardUserDefaults]
                 setObject:userinfoDic
                 forKey:_anncMsg.anncPublisher];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [weakSelf.conversationListTableView
                   reloadRowsAtIndexPaths:@[ indexPath ]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
    } else{
        userName = model.extend;
    }
    WFYChatsAnncCell * cell = [[WFYChatsAnncCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@""];
    //头像
    cell.ivAva.image = [UIImage imageNamed:@"system_notice"];
    //描述
    cell.lblDetail.text = [NSString stringWithFormat:@"%@:%@",userName,_anncMsg.anncTopic];
    //时间
    cell.labelTime.text = [RCKitUtility ConvertMessageTime:model.sentTime/1000];
    return cell;
}



//*********************插入自定义Cell*********************//

/**
 *重写收到消息处理,在方法里生成新的 model，插入会话列表数据源 conversationListDataSource，更新页面，生成的 model 类型 conversationModelType 必须是 RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION
 */
#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification{
    __weak typeof(&*self) blockSelf_ = self;
    //处理公告消息
    RCMessage *message = notification.object;
    if ([message.content isMemberOfClass:[WFYAnnouncementMessage class]]) {
        
        if (message.conversationType != ConversationType_SYSTEM) {
            NSLog(@"公告消息要发系统消息！！！");
#if DEBUG
            @throw [[NSException alloc]
                    initWithName:@"error"
                    reason:@"公告消息要发系统消息！！！"
                    userInfo:nil];
#endif
        }
        WFYAnnouncementMessage *_anncMsg = (WFYAnnouncementMessage *)message.content;
        if (_anncMsg.announcementId == nil || _anncMsg.announcementId.length == 0) {
            return;
        }
        //根据公告id获取公告概要信息,存储在本地
        [WFHTTPTOOL getAnnouncementByID:_anncMsg.announcementId
                      successCompletion:^(WFYAnnouncementModel *model) {
              if (model.anncPublisher == nil || model.anncPublisher.length == 0) {
                  return;
              }
              [[WFDataBaseManager shareInstance]insertAnnouncementToDB:model];
              [WFHTTPTOOL getUserInfoByUserID:model.anncPublisher
                                   completion:^(RCUserInfo *user) {
                           RCConversationModel *customModel = [RCConversationModel new];
                           customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                           customModel.extend = user.name;//自定义的扩展数据存放发布者的姓名
                           customModel.targetId = message.targetId;
                           customModel.sentTime = message.sentTime;
                           customModel.receivedTime = message.receivedTime;
                           customModel.senderUserId = message.senderUserId;
                           customModel.lastestMessage = _anncMsg;
                           // local cache for userInfo
                           NSDictionary *userinfoDic = @{
                                                         @"username" : user.name,
                                                         @"portraitUri" : user.portraitUri
                                                         };
                           [[NSUserDefaults standardUserDefaults]
                            setObject:userinfoDic
                            forKey:model.anncPublisher];
                           [[NSUserDefaults standardUserDefaults] synchronize];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               //调用父类刷新未读消息数
                               [blockSelf_
                                refreshConversationTableViewWithConversationModel:
                                customModel];
                               [self notifyUpdateUnreadMessageCount];
                               //当消息为WFYAnnouncementMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表
                               //notification的object为RCMessage消息对象，userInfo为NSDictionary对象，其中key值为@"left"，value为还剩余未接收的消息数的NSNumber对象
                               NSNumber *left = [notification.userInfo objectForKey:@"left"];
                               if (0 == left.integerValue) {
                                   [super refreshConversationTableViewIfNeeded];
                               }
                           });
               }];
        }];
    } else {
        //调用父类刷新未读消息数
        [super didReceiveMessageNotification:notification];
    }
}

/*!
 点击Cell头像的回调
 
 @param model   会话Cell的数据模型
 */
- (void)didTapCellPortrait:(RCConversationModel *)model{
    if (model.conversationModelType ==
        RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        ChatContr *_conversationVC =
        [[ChatContr alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.title = model.conversationTitle;//想显示的会话标题
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        [self.navigationController pushViewController:_conversationVC
                                             animated:YES];
    }
    
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        ChatContr *_conversationVC =
        [[ChatContr alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.title = model.conversationTitle;
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
        _conversationVC.enableUnreadMessageIcon = YES;
        if (model.conversationType == ConversationType_SYSTEM) {
            _conversationVC.title = @"系统消息";
        }
        //收到公告的通知消息
        if ([model.objectName isEqualToString:WFYAnnouncementMessageTypeIdentifier]) {
            WFYAnnouncementContr *announcementVC = [[WFYAnnouncementContr alloc]init];
            [self.navigationController pushViewController:announcementVC animated:YES];
            return;
        }
        //如果是单聊，不显示发送方昵称
        if (model.conversationType == ConversationType_PRIVATE) {
            _conversationVC.displayUserNameInCell = NO;
        }
        [self.navigationController pushViewController:_conversationVC
                                             animated:YES];
    }
    //聚合会话类型，此处自定设置。
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        ChatsContr *temp =
        [[ChatsContr alloc] init];
        NSArray *array = [NSArray
                          arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
    
    //自定义会话类型
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
//        RCConversationModel *model =
//        self.conversationListDataSource[indexPath.row];
        //收到公告的通知消息
        if ([model.objectName isEqualToString:WFYAnnouncementMessageTypeIdentifier]) {
            WFYAnnouncementContr *announcementVC = [[WFYAnnouncementContr alloc]init];
            [self.navigationController pushViewController:announcementVC animated:YES];
        }
    }
}

@end
