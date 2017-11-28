//
//  WFYTransmitCollectionContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYTransmitCollectionContr.h"
#import "WFYCollectionCell.h"
#import "WFYCollectionModel.h"
#import "WFYCollectMessage.h"
#import "WFYSendCollectionPopupWindow.h"
#import <RongIMKit/RongIMKit.h>

@interface WFYTransmitCollectionContr ()<UITableViewDataSource, UITableViewDelegate,WFYSendCollectionPopupWindowDelegate>

@property(assign,nonatomic) RCConversationType rConversationType;
@property(strong,nonatomic) NSString *sTargetId;
/** 当前用户收藏的所有消息 */
@property(nonatomic, strong) NSArray<WFYCollectionModel *> *collections;

@end

@implementation WFYTransmitCollectionContr
{
    CGFloat _cellHeight;
    UITableView *_tableView;
}

- (instancetype)initWithConversationType:(RCConversationType) conversationType WithTargetId:(NSString *) targetId{
    self = [super init];
    if (self != nil) {
        _rConversationType =conversationType;
        _sTargetId = targetId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIvar];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self bindUIValue2];
}

- (void)initIvar
{

}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI{
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
}

- (void)bindUIValue{
    self.title = @"我的收藏";
    
    _tableView.backgroundColor = RGB(245, 245, 245);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.bounces = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}

- (void)layoutUI{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    _tableView.frame = CGRectMake(0, 0, sw, sh);
}

//- (void)bindUIValue2{
//    _collections = [[WFDataBaseManager shareInstance]getAllCollection];
//    [_tableView reloadData];
//}

- (void)bindUIValue2
{
    //发送网络请求，获取当前用户的所有收藏信息，同时更新到本地数据库
    [WFHTTPTOOL getMyCollectionsWithBlock:^(NSMutableArray *result) {
        if (result.count>0) {
            dispatch_async(
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                               NSMutableArray *tempCollections = [NSMutableArray arrayWithArray:[[WFDataBaseManager shareInstance] getAllCollection]];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   _collections = tempCollections;
                                   if ([_collections count]>0) {
                                       NSLog(@"%@",_collections);
                                       [_tableView reloadData];
                                   }
                               });
                           });
        };
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _collections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    WFYCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[WFYCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    //cellForRowAtIndexPath先于heightForRowAtIndexPath执行，为了计算frame提前调用cellHeight的get方法
    _cellHeight= _collections[indexPath.section].cellHeight;
    cell.collection = _collections[indexPath.section];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _collections[indexPath.section].cellHeight;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 0.00001;
    }
    return 5;//section头部高度
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView;
    if (section == 0)
        headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.00001)];
    else
        headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 5)];
    headView.backgroundColor = RGB(245, 245, 245);
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.00001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //弹出确认页面，页面中增加一个留言栏，作为文本聊天消息发出
    WFYSendCollectionPopupWindow *vc = [[WFYSendCollectionPopupWindow alloc]init];
    vc.delegate =self;
    vc.providesPresentationContextTransitionStyle = YES;
    vc.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
    /*
    //发送网络请求，通过服务器发送自定义消息
    NSMutableArray *arr = [NSMutableArray arrayWithObject:self.sTargetId];
    if (_rConversationType == ConversationType_PRIVATE) {
        [WFHTTPTOOL sendPrivateCollectionMsgWithUserId:arr
                                          CollectionId:_collections[indexPath.section].collectionId
                                              complete:^(BOOL isOK) {
                                                  if (isOK) {
                                                      NSLog(@"公告消息发送成功");
                                                      [self.navigationController popViewControllerAnimated:NO];
                                                  }
                                                  else{
                                                      NSLog(@"公告消息发送失败");
                                                  }

                                              }];
    }else{
        [WFHTTPTOOL sendGroupCollectionMsgWithUserId:arr
                                          CollectionId:_collections[indexPath.section].collectionId
                                              complete:^(BOOL isOK) {
                                                  if (isOK) {
                                                      NSLog(@"公告消息发送成功");
                                                      [self.navigationController popViewControllerAnimated:NO];
                                                  }
                                                  else{
                                                      NSLog(@"公告消息发送失败");
                                                  }
                                                  
                                              }];
    }
    */
}

#pragma mark  WFYSendCollectionPopupWindowDelegate
- (void)sendTransmitCollectionMsgClicked:(NSIndexPath *)indexPath WithLeaveWord:(NSString *)leaveWord{
    if ([leaveWord length] >0) {
        //去除首尾的空格
        leaveWord = [leaveWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //去除首尾的换行
        leaveWord = [leaveWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        RCTextMessage *leaveWordMsg = [RCTextMessage messageWithContent:leaveWord];
        [[RCIM sharedRCIM] sendMessage:_rConversationType
                              targetId:_sTargetId
                               content:leaveWordMsg
                           pushContent:nil
                              pushData:nil
                               success:^(long messageId) {
                                   WFYCollectMessage *msg = [WFYCollectMessage messageWithContent:_collections[indexPath.section].collectionTitle CollectionId:_collections[indexPath.section].collectionId];
                                   [[RCIM sharedRCIM] sendMessage:_rConversationType
                                                         targetId:_sTargetId
                                                          content:msg
                                                      pushContent:nil
                                                         pushData:nil
                                                          success:^(long messageId) {
                                                              //
                                                          }
                                                            error:^(RCErrorCode nErrorCode, long messageId) {
                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                                                message:@"收藏转发消息发送失败"
                                                                                                               delegate:nil
                                                                                                      cancelButtonTitle:@"确定"
                                                                                                      otherButtonTitles: nil];
                                                                [alert show];
                                                            }];
                                   [self.navigationController popViewControllerAnimated:NO];
                                   dispatch_after(
                                                  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                                                      
                                                  });
                               } error:^(RCErrorCode nErrorCode, long messageId) {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                   message:@"收藏转发消息发送失败"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles: nil];
                                   [alert show];
                               }];
    
    }else{
        WFYCollectMessage *msg = [WFYCollectMessage messageWithContent:_collections[indexPath.section].collectionTitle CollectionId:_collections[indexPath.section].collectionId];
        [[RCIM sharedRCIM] sendMessage:_rConversationType
                              targetId:_sTargetId
                               content:msg
                           pushContent:nil
                              pushData:nil
                               success:^(long messageId) {
                                   //
                               }
                                 error:^(RCErrorCode nErrorCode, long messageId) {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                     message:@"收藏转发消息发送失败"
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"确定"
                                                                           otherButtonTitles: nil];
                                     [alert show];
                                 }];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
