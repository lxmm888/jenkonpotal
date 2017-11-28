//
//  ChatContr.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/10.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "ChatContr.h"
#import <RongCallKit/RongCallKit.h>
#import "WFUIBarButtonItem.h"
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"
#import "AppSession.h"
#import "WFGroupSettingsContr.h"
#import "WFGroupInfo.h"
#import "StaffInfoContr.h"
#import "StaffModel.h"
#import "UsrInfoApi.h"
#import "APPWebMgr.h"
#import "SVProgressHUD.h"
#import "WFYQuickReplyPopupWindow.h"
#import "WFYTransmitCollectionContr.h"
#import "RCDTestMessage.h"
#import "RCDTestMessageCell.h"
#import "WFYCollectMessage.h"
#import "WFYCollectMessageCell.h"
#import "WFYAnncWebViewContr.h"


#define chatCallViewTag 2000
#define chatQuickReplyTag 2001
#define chatCollectionTag 2002

@interface ChatContr ()<UIActionSheetDelegate,RCRealTimeLocationObserver,
RealTimeLocationStatusViewDelegate, UIAlertViewDelegate,
RCMessageCellDelegate,RCMessageCellDelegate>

@property(nonatomic, weak) id<RCRealTimeLocationProxy> realTimeLocation;
@property(nonatomic, strong) RealTimeLocationStatusView *realTimeLocationStatusView;
@property(nonatomic, strong) WFGroupInfo *groupInfo;

@property(nonatomic)BOOL isLoading;

@end

NSMutableDictionary *userInputStatus;//实现底部输入框模式记忆功能

@implementation ChatContr
{
    UILabel *_backLabel;
    UsrInfoApi *_usrInfoApi;
    APPWebMgr *_webMgr;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self bindUIValue2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //记录会话页面下方的输入工具栏当前的输入状态
    KBottomBarStatus inputType = self.chatSessionInputBarControl.currentBottomBarStatus;
    if (!userInputStatus) {
        userInputStatus = [NSMutableDictionary new];
    }
    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@",(unsigned long)self.conversationType,self.targetId];
    [userInputStatus setObject:[NSString stringWithFormat:@"%ld",(long)inputType] forKey:userInputStatusKey];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIvar];
    [self initUI];
}

- (void)initIvar{
    _usrInfoApi = [[UsrInfoApi alloc] init];
    _webMgr = [APPWebMgr manager];
    _usrInfoApi.webDelegate = _webMgr;
}

- (void)initUI
{
    [self bindLeftItem];
    [self bindRightItem];
    [self bindUIValue];
    _isLoading = NO;
}

- (void)bindLeftItem
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc]
                            initWithImage:[UIImage imageNamed:@"navi_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self
                action:@selector(tapBack:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    _backLabel = backText;
}

- (void)bindRightItem
{
    if (self.conversationType != ConversationType_CHATROOM) {
        if (self.conversationType == ConversationType_DISCUSSION) {
            [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
                 success:^(RCDiscussion *discussion) {
                     if (discussion != nil && discussion.memberIdList.count > 0) {
                         if ([discussion.memberIdList
                              containsObject:[RCIMClient sharedRCIMClient]
                              .currentUserInfo.userId]) {
                             [self setRightNavigationItem:[UIImage
                                                           imageNamed:@"Private_Setting"]
                                                withFrame:CGRectMake(15, 3.5, 16, 18.5)];
                         } else {
                             self.navigationItem.rightBarButtonItem = nil;
                         }
                     }
                 }
                   error:^(RCErrorCode status){
                   }];
        } else if (self.conversationType == ConversationType_GROUP) {
            [self setRightNavigationItem:[UIImage imageNamed:@"Group_Setting"]
                               withFrame:CGRectMake(10, 3.5, 21, 19.5)];
        } else {
            [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"]
                               withFrame:CGRectMake(15, 3.5, 16, 18.5)];
        }
        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)bindUIValue
{
    self.enableUnreadMessageIcon = YES;
    self.enableNewComingMessageIcon = YES;
    self.enableSaveNewPhotoToLocalSystem = YES;//发送新拍照的图片完成之后，是否将图片在本地另行存储
    
    //注册自定义消息Cell
    [self registerCellClass];
    
    ///注册自定义测试消息Cell
    [self registerClass:[RCDTestMessageCell class] forMessageClass:[RCDTestMessage class]];
    
    [self registerClass:[WFYCollectMessageCell class] forMessageClass:[WFYCollectMessage class]];
    
    // 移除 加号-位置
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
    // 添加 加号-通话
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"actionbar_phone_icon"] title:@"通话" atIndex:2 tag:chatCallViewTag];
    // 添加 加号-快捷回复
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"actionbar_reply_icon"]
                                                                   title:@"快捷回复"
                                                                 atIndex:0
                                                                     tag:chatQuickReplyTag];
    // 添加 加号-公告
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"actionbar_collect_icon"]
                                                                   title:@"收藏"
                                                                 atIndex:1
                                                                     tag:chatCollectionTag];
    
    // 左上未读数
    [self notifyUpdateUnreadMessageCount];
    
    if (self.conversationType != ConversationType_APPSERVICE && self.conversationType != ConversationType_PUBLICSERVICE) {
        //加号区域增加发送文件功能，Kit中已经默认实现了该功能，但是为了SDK向后兼容性，目前SDK默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        UIImage *imageFile = [RCKitUtility imageNamed:@"actionbar_file_icon"
                                             ofBundle:@"RongCloud.bundle"];
        [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:imageFile
                                                                       title:NSLocalizedStringFromTable(@"文件", @"RongCloudKit", nil)
                                                                     atIndex:3
                                                                         tag:PLUGIN_BOARD_ITEM_FILE_TAG];
    }
    
    //刷新个人或群组的信息
    [self refreshUserInfoOrGroupInfo];
    
    if (self.conversationType == ConversationType_GROUP) {
        //群组改名之后，更新当前页面的Title
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTitleForGroup:)
                                                     name:@"UpdeteGroupInfo"
                                                   object:nil];
    }
    
    //清除历史消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMSG:)
                                                 name:@"ClearHistoryMsg"
                                               object:nil];
}

- (void)updateTitleForGroup:(NSNotification *)notification {
    NSString *groupId = notification.object;
    if ([groupId isEqualToString:self.targetId]) {
        WFGroupInfo *tempInfo = [[WFDataBaseManager shareInstance] getGroupByGroupId:self.targetId];
        
        int count = tempInfo.number.intValue;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = [NSString stringWithFormat:@"%@(%d)",tempInfo.groupName,count];
        });
    }
}

- (void)bindUIValue2{
    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@",(unsigned long)self.conversationType,self.targetId];
    if (userInputStatus && [userInputStatus.allKeys containsObject:userInputStatusKey]) {
        KBottomBarStatus inputType = (KBottomBarStatus)[userInputStatus[userInputStatusKey] integerValue];
        //输入框记忆功能，如果退出时是语音输入，再次进入默认语音输入
        if (inputType == KBottomBarRecordStatus) {
            self.defaultInputType = RCChatSessionInputBarInputVoice;
        } else if (inputType == KBottomBarPluginStatus) {
            //      self.defaultInputType = RCChatSessionInputBarInputExtention;
        }
    }
}

- (void)clearHistoryMSG:(NSNotification *)notification {
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}

-(void)registerCellClass{
    /*******************实时地理位置共享***************/
    [self registerClass:[RealTimeLocationStartCell class]
        forMessageClass:[RCRealTimeLocationStartMessage class]];
    [self registerClass:[RealTimeLocationEndCell class]
        forMessageClass:[RCRealTimeLocationEndMessage class]];
    
    __weak typeof(&*self) weakSelf = self;
    [[RCRealTimeLocationManager sharedManager]
     getRealTimeLocationProxy:self.conversationType
     targetId:self.targetId
     success:^(id<RCRealTimeLocationProxy> realTimeLocation) {
         weakSelf.realTimeLocation = realTimeLocation;
         [weakSelf.realTimeLocation addRealTimeLocationObserver:self];
         [weakSelf updateRealTimeLocationStatus];
     }
     error:^(RCRealTimeLocationErrorCode status) {
         NSLog(@"get location share failure with code %d", (int)status);
     }];
    
    /******************实时地理位置共享**************/
}

/**
 * 退出会话页面
 * 退出会话页面有时需要直接退出到根页面，有时需要退回到上一个页面，需要定义一个属性来标识
 */
- (void)tapBack:(id)sender
{
    //
    if ([self.realTimeLocation getStatus] ==
            RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] ==
            RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"离开聊天，位置共享也会结束，确认离开"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        alertView.tag= 101;
        [alertView show];
    } else {
        [self popupChatViewController];
    }
    
}

- (void)popupChatViewController{
    [super leftBarButtonItemPressed:nil];
    [self.realTimeLocation removeRealTimeLocationObserver:self];
    if (_needPopToRootView ==YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image
    didFinishSavingWithError:(NSError *)error
                 contextInfo:(void *)contextInfo {
}

- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    WFUIBarButtonItem *rightBtn = [[WFUIBarButtonItem alloc]
                                    initContainImage:image
                                    imageViewFrame:frame
                                    buttonTitle:nil
                                    titleColor:nil
                                    titleFrame:CGRectZero
                                    buttonFrame:CGRectMake(0, 0, 25, 25)
                                    target:self
                                    action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

/**
 *  可以根据需求使用自定义设置
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    if (self.conversationType == ConversationType_PRIVATE) {
        //进入点对点聊天详情页面，可以查看或清除聊天记录
    }
    //群组设置
    else if (self.conversationType == ConversationType_GROUP){
        WFGroupSettingsContr *settingsVC =
        [WFGroupSettingsContr groupSettingsContr];
        if (_groupInfo == nil) {
            settingsVC.Group =
            [[WFDataBaseManager shareInstance] getGroupByGroupId:self.targetId];
        } else {
            
            settingsVC.Group = _groupInfo;
        }
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
}

// override
- (void)notifyUpdateUnreadMessageCount
{
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                @(ConversationType_PRIVATE),
                                                                @(ConversationType_DISCUSSION),
                                                                @(ConversationType_APPSERVICE),
                                                                @(ConversationType_PUBLICSERVICE),
                                                                @(ConversationType_GROUP)
                                                                ]];
    
    NSString *backString = nil;
    if (count > 0 && count < 1000) {
        backString = [NSString stringWithFormat:@"消息(%d)", count];
    } else if (count >= 1000) {
        backString = @"消息(...)";
    } else {
        backString = @"消息";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _backLabel.text = backString;
    });
}

/*
 *弹出快捷回复选择框
 */
- (void)quickReply
{
    WFYQuickReplyPopupWindow *vc = [[WFYQuickReplyPopupWindow alloc]init];
    vc.rConversationType =self.conversationType;
    vc.sTargetId = self.targetId;
    
    vc.providesPresentationContextTransitionStyle = YES;
    vc.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
};

/*
 *弹出收藏内容选择页面
 */
- (void)transmitCollection
{
    WFYTransmitCollectionContr *vc =[[WFYTransmitCollectionContr alloc]initWithConversationType:self.conversationType WithTargetId:self.targetId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onCall
{
    if (self.conversationType==ConversationType_PRIVATE) {
        
        [[RCCall sharedRCCall] startSingleCall:self.targetId mediaType:RCCallMediaAudio];//音频
        
    }else if (self.conversationType==ConversationType_DISCUSSION) {
        
        [[RCCall sharedRCCall] startMultiCall:ConversationType_DISCUSSION targetId:self.targetId mediaType:RCCallMediaAudio];
        
    }else if (self.conversationType==ConversationType_GROUP){
        [[RCCall sharedRCCall] startMultiCall:ConversationType_DISCUSSION targetId:self.targetId mediaType:RCCallMediaAudio];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (RealTimeLocationStatusView *)realTimeLocationStatusView {
    if (!_realTimeLocationStatusView) {
        _realTimeLocationStatusView = [[RealTimeLocationStatusView alloc]
                                       initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
        _realTimeLocationStatusView.delegate = self;
        [self.view addSubview:_realTimeLocationStatusView];
    }
    return _realTimeLocationStatusView;
}

#pragma mark - RCPluginBoardViewDelegate

// override
// 点击扩展功能板中的扩展项的回调
- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    switch (tag) {
        case chatQuickReplyTag:
            [self quickReply];
            break;
        case chatCollectionTag:
            [self transmitCollection];
            break;
        case chatCallViewTag:
            [self onCall];
            break;
        case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
            if (self.realTimeLocation) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                              initWithTitle:nil
                                              delegate:self
                                              cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:nil
                                              otherButtonTitles:@"发送位置", @"位置实时共享", nil];
                [actionSheet showInView:self.view];
            } else {
                [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            }
            
        } break;
            
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [super pluginBoardView:self.pluginBoardView
                clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
        } break;
        case 1: {
            [self showRealTimeLocationViewController];
        } break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    SEL selector = NSSelectorFromString(@"_alertController");
    
    if ([actionSheet respondsToSelector:selector]) {
        UIAlertController *alertController =
        [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]]) {
            alertController.view.tintColor = [UIColor blackColor];
        }
    } else {
        for (UIView *subView in actionSheet.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - RealTimeLocationStatusViewDelegate
- (void)onJoin {
    [self showRealTimeLocationViewController];
}
- (RCRealTimeLocationStatus)getStatus {
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}
- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    //可以在这里修改将要发送的消息
    if ([messageContent isMemberOfClass:[RCTextMessage class]]) {
        // RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        // textMsg.extra = @"";
    }
    return messageContent;
}

#pragma mark - RCRealTimeLocationObserver
- (void)onRealTimeLocationStatusChange:(RCRealTimeLocationStatus)status {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onReceiveLocation:(CLLocation *)location fromUserId:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onParticipantsJoin:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient]
         .currentUserInfo.userId]) {
        [self notifyParticipantChange:@"你加入了地理位置共享"];
    } else {
        [[RCIM sharedRCIM]
         .userInfoDataSource
         getUserInfoWithUserId:userId
         completion:^(RCUserInfo *userInfo) {
             if (userInfo.name.length) {
                 [weakSelf
                  notifyParticipantChange:
                  [NSString stringWithFormat:@"%@加入地理位置共享",
                   userInfo.name]];
             } else {
                 [weakSelf
                  notifyParticipantChange:
                  [NSString
                   stringWithFormat:@"user<%@>加入地理位置共享",
                   userId]];
             }
         }];
    }
}

- (void)onParticipantsQuit:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient]
         .currentUserInfo.userId]) {
        [self notifyParticipantChange:@"你退出地理位置共享"];
    } else {
        [[RCIM sharedRCIM]
         .userInfoDataSource
         getUserInfoWithUserId:userId
         completion:^(RCUserInfo *userInfo) {
             if (userInfo.name.length) {
                 [weakSelf
                  notifyParticipantChange:
                  [NSString stringWithFormat:@"%@退出地理位置共享",
                   userInfo.name]];
             } else {
                 [weakSelf
                  notifyParticipantChange:
                  [NSString
                   stringWithFormat:@"user<%@>退出地理位置共享",
                   userId]];
             }
         }];
    }
}

- (void)onRealTimeLocationStartFailed:(long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_FAILED;
            }
        }
        NSArray *visibleItem =
        [self.conversationMessageCollectionView indexPathsForVisibleItems];
        for (int i = 0; i < visibleItem.count; i++) {
            NSIndexPath *indexPath = visibleItem[i];
            RCMessageModel *model =
            [self.conversationDataRepository objectAtIndex:indexPath.row];
            if (model.messageId == messageId) {
                [self.conversationMessageCollectionView
                 reloadItemsAtIndexPaths:@[ indexPath ]];
            }
        }
    });
}

- (void)notifyParticipantChange:(NSString *)text {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.realTimeLocationStatusView updateText:text];
        [weakSelf performSelector:@selector(updateRealTimeLocationStatus)
                       withObject:nil
                       afterDelay:0.5];
    });
}

- (void)onFailUpdateLocation:(NSString *)description {
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 101: {
            if (buttonIndex == 1) {
                [self.realTimeLocation quitRealTimeLocation];
                [self popupChatViewController];
            }
        }
            break;
            
            break;
        default:
            break;
    }
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    return message;
}

/*******************实时地理位置共享***************/
- (void)showRealTimeLocationViewController {
    RealTimeLocationViewController *lsvc =
    [[RealTimeLocationViewController alloc] init];
    lsvc.realTimeLocationProxy = self.realTimeLocation;
    if ([self.realTimeLocation getStatus] ==
        RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        [self.realTimeLocation joinRealTimeLocation];
    } else if ([self.realTimeLocation getStatus] ==
               RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        [self.realTimeLocation startRealTimeLocation];
    }
    [self.navigationController presentViewController:lsvc
                                            animated:YES
                                          completion:^{
                                              
                                          }];
}


- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(&*self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
            case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
                [self.realTimeLocationStatusView updateText:@"你正在共享位置"];
                break;
            case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
            case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
                participants = [self.realTimeLocation getParticipants];
                if (participants.count == 1) {
                    NSString *userId = participants[0];
                    [weakSelf.realTimeLocationStatusView
                     updateText:[NSString
                                 stringWithFormat:@"user<%@>正在共享位置", userId]];
                    [[RCIM sharedRCIM]
                     .userInfoDataSource
                     getUserInfoWithUserId:userId
                     completion:^(RCUserInfo *userInfo) {
                         if (userInfo.name.length) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.realTimeLocationStatusView
                                  updateText:[NSString stringWithFormat:
                                              @"%@正在共享位置",
                                              userInfo.name]];
                             });
                         }
                     }];
                } else {
                    if (participants.count < 1)
                        [self.realTimeLocationStatusView removeFromSuperview];
                    else
                        [self.realTimeLocationStatusView
                         updateText:[NSString stringWithFormat:@"%d人正在共享地理位置",
                                     (int)participants.count]];
                }
                break;
            default:
                break;
        }
    }
}

-(NSArray *)sortForHasReadList: (NSDictionary *)readReceiptUserDic {
    NSArray *result;
    NSArray *sortedKeys = [readReceiptUserDic keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    result = [sortedKeys copy];
    return result;
}

- (BOOL)stayAfterJoinChatRoomFailed {
    //加入聊天室失败之后，是否还停留在会话界面
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"stayAfterJoinChatRoomFailed"] isEqualToString:@"YES"];
}

- (void)alertErrorAndLeft:(NSString *)errorInfo {
    if (![self stayAfterJoinChatRoomFailed]) {
        [super alertErrorAndLeft:errorInfo];
    }
}

#pragma Load More Chatroom History Message From Server
//需要开通聊天室消息云端存储功能，调用getRemoteChatroomHistoryMessages接口才可以从服务器获取到聊天室消息的数据
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate{
    //当会话类型是聊天室时，下拉加载消息会调用getRemoteChatroomHistoryMessages接口从服务器拉取聊天室消息
    if (self.conversationType == ConversationType_CHATROOM) {
        if (scrollView.contentOffset.y < -15.0f && !_isLoading) {
            _isLoading = YES;
            [self performSelector:@selector(loadMoreChatroomHistoryMessageFromServer) withObject:nil afterDelay:0.4f];
        }
    } else {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

//从服务器拉取聊天室消息的方法
- (void)loadMoreChatroomHistoryMessageFromServer{
    long long recordTime = 0;
    RCMessageModel *model;
    if (self.conversationDataRepository.count > 0) {
        model = [self.conversationDataRepository objectAtIndex:0];
        recordTime = model.sentTime;
    }
    __weak typeof(self)weakSelf = self;
    [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:self.targetId recordTime:recordTime count:20 order:RC_Timestamp_Desc success:^(NSArray *messages, long long syncTime) {
        _isLoading = NO;
        [weakSelf handleMessages:messages];
    } error:^(RCErrorCode status) {
        NSLog(@"load remote history message failed(%zd)", status);
    }];
}

//对于从服务器拉取到的聊天室消息的处理
- (void)handleMessages:(NSArray *)messages{
    NSMutableArray *tempMessags = [[NSMutableArray alloc] initWithCapacity:0];
    for (RCMessage *message in messages) {
        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
        [tempMessags addObject:model];
    }
    //对去拉取到的消息进行逆序排列
    NSArray *reversedArray = [[tempMessags reverseObjectEnumerator] allObjects];
    tempMessags = [reversedArray mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        //将逆序排列的消息加入到数据源
        [tempMessags addObjectsFromArray:self.conversationDataRepository];
        self.conversationDataRepository = tempMessags;
        //显示消息发送时间的方法
        [self figureOutAllConversationDataRepository];
        [self.conversationMessageCollectionView reloadData];
        if (self.conversationDataRepository != nil &&
            self.conversationDataRepository.count > 0 &&
            [self.conversationMessageCollectionView numberOfItemsInSection:0] >=
            messages.count - 1) {
            NSIndexPath *indexPath =
            [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
            [self.conversationMessageCollectionView
             scrollToItemAtIndexPath:indexPath
             atScrollPosition:UICollectionViewScrollPositionTop
             animated:NO];
        }
    });
}

//显示消息发送时间的方法
- (void)figureOutAllConversationDataRepository {
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
        } else if (i > 0) {
            RCMessageModel *pre_model =
            [self.conversationDataRepository objectAtIndex:i - 1];
            
            long long previous_time = pre_model.sentTime;
            
            long long current_time = model.sentTime;
            
            long long interval = current_time - previous_time > 0
            ? current_time - previous_time
            : previous_time - current_time;
            if (interval / 1000 <= 3*60) {
                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height-45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = NO;
            }
        }
    }
}

#pragma mark RCMessageCellDelegate
- (void)didTapCellPortrait:(NSString *)userId{
    //发送网络请求，通过id获取成员信息
    _usrInfoApi.usrname = userId;
    [_usrInfoApi connect:^(ApiRespModel *resp) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            return;
        } else {
            NSDictionary *usrInfo = resp.resultset[@"success"][@"response"];
            StaffModel *staff= [[StaffModel alloc]init];
            staff.uid=  [usrInfo[@"UserID"] integerValue];
            staff.usrname = usrInfo[@"UserName"];
            staff.nickname = usrInfo[@"NickName"];
            staff.avatarUri = usrInfo[@"Avatar"];
            staff.email = usrInfo[@"Email"];
            [self gotoNextPage:staff];
        }
    } :^(NSError *error) {
        XILog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    //获取成功后，先刷新本地缓存，然后跳转页面
    
}

/**
 *跳转页面，进入个人信息详情页面，可以发起会话，发起语音或视频聊天
 */
- (void)gotoNextPage:(StaffModel *)staff{
    StaffInfoContr *c = [[StaffInfoContr alloc] init];
    c.staff = staff;
    [self.navigationController pushViewController:c animated:YES];
}

                                  
- (void)refreshTitle{
  if (self.targetId == nil) {
      return;
  }
  int count = [[[WFDataBaseManager shareInstance] getGroupByGroupId:self.targetId].number intValue];
  if (self.conversationType == ConversationType_GROUP && count > 0){
      self.title = [NSString stringWithFormat:@"%@(%d)",self.groupInfo.groupName,count];
  }else{
      self.title = self.groupInfo.groupName;
  }
}


#pragma mark private method
- (void)refreshUserInfoOrGroupInfo {
    //打开单聊强制从demo server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            __weak typeof(self) weakSelf = self;
            XILog(@"打开单聊强制从demo server 获取用户信息更新本地数据库,代码未完成。。。");
        }
    }
    //刷新自己头像昵称
    
    
    
    //打开群聊强制从demo server 获取群组信息更新本地数据库
    if (self.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        NSString * groupIdStr = [NSString stringWithFormat:@"%@",self.targetId];
        //根据id获取单个群组
        [WFHTTPTOOL getGroupByID:groupIdStr
               successCompletion:^(WFGroupInfo *group) {
                   _groupInfo = group;
                   RCGroup *Group = [[RCGroup alloc] initWithGroupId:groupIdStr
                                                           groupName:group.groupName
                                                         portraitUri:group.portraitUri];
                   [[RCIM sharedRCIM] refreshGroupInfoCache:Group
                                                withGroupId:groupIdStr];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf refreshTitle];
                   });
               }];
    }
    //更新群组成员用户信息的本地缓存
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *groupList =
        [[WFDataBaseManager shareInstance] getGroupMember:self.targetId];
        for (RCUserInfo *user in groupList) {
            if ([user.portraitUri isEqualToString:@""]) {
                user.portraitUri = [AppSession defaultUserPortrait:user];
            }
            if ([user.portraitUri hasPrefix:@"file:///"]) {
                NSString *filePath = [AppSession
                                      getIconCachePath:[NSString
                                                        stringWithFormat:@"user%@.png", user.userId]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
                    user.portraitUri = [portraitPath absoluteString];
                } else {
                    user.portraitUri = [AppSession defaultUserPortrait:user];
                }
            }
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
        }
    });
}

#pragma mark RCMessageCellDelegate
- (void) didTapMessageCell:(RCMessageModel *)model{
    //if ([message.content isMemberOfClass:[WFYAnnouncementMessage class]]) {
    if ([model.content isMemberOfClass:[WFYCollectMessage class]]) {
        NSLog(@"%s",__func__);
        WFYAnncWebViewContr *c = [[WFYAnncWebViewContr alloc] init];
        c.announcementId = @"43";
        [self.navigationController pushViewController:c animated:YES];
    }
}

@end
