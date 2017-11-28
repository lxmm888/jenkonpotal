//
//  WFYAnnouncementContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/14.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnnouncementContr.h"
#import "WFYAnncCell.h"
#import "UIView+AddLongPressEvent.h"
#import "KxMenu.h"
#import "AppFontMgr.h"
#import "ShowAnimationView.h"
#import "WFDataBaseManager.h"
#import "WFYAnnouncementModel.h"
#import "NSString+Kit.h"
#import "AppConf.h"
#import "UIView+AddClickedEvent.h"
#import "WFYAnncWebViewContr.h"
#import "WFYAnnouncementModel.h"
#import "WFYAnnouncementPopupWindow.h"

@interface WFYAnnouncementContr ()<UITableViewDataSource, UITableViewDelegate,WFYAnnouncementPopupWindowDelegate>

/** 当前用户接收到的所有公告消息 */
@property(nonatomic, strong) NSMutableArray<WFYAnnouncementModel *> *announcements;

@end

@implementation WFYAnnouncementContr
{
    UITableView *_tableView;
    UILabel * _notifyTip;
    UIImageView *_notifyImg;
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

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self bindLeftItem];
    [self layoutUI];
}

- (void)createUI
{
    _tableView = [[UITableView alloc] init];
    _notifyTip = [[UILabel alloc]init];
    _notifyImg = [[UIImageView alloc]init];
    [self.view addSubview:_tableView];
    [self.view addSubview:_notifyTip];
    [self.view addSubview:_notifyImg];
}

- (void)bindUIValue
{
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.bounces=NO;
    _tableView.backgroundColor = RGB(235, 235, 235);
    
    _notifyTip.text = @"当前没有公告";
    _notifyTip.textColor = RGB(102, 102, 102);
    _notifyTip.textAlignment =NSTextAlignmentCenter;
    _notifyTip.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1];
    [_notifyTip setHidden:YES];
    
    _notifyImg.image = [UIImage imageNamed:@"nothingNotify.png"];
    _notifyImg.userInteractionEnabled = NO;
    [_notifyImg setHidden:YES];
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
    backText.text = @"公告";
    [backBtn addSubview:backText];
    [backBtn addTarget:self
                action:@selector(tapBack:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    CGFloat topMargin = kStatusBarH+kNaviBarH;
    
    _tableView.frame = CGRectMake(0, 0, sw, sh-topMargin);
    
    CGFloat notifyTipW = sw*0.5;
    CGFloat notifyTipH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                 withFont:[UIFont systemFontOfSize:[AppFontMgr standardFontSize]]].height;
    CGFloat notifyTipX = (sw-notifyTipW)/2.0;
    CGFloat notifyTipY = (sh-topMargin-notifyTipH)/2.0;
    _notifyTip.frame = CGRectMake(notifyTipX, notifyTipY, notifyTipW, notifyTipH);
    
    CGFloat notifyImgW = 100;
    CGFloat notifyImgH = notifyImgW;
    CGFloat notifyImgX = SCREEN_WIDTH/2.0 -notifyImgW/2.0;
    CGFloat notifyImgY = CGRectGetMinY(_notifyTip.frame)-notifyImgH-notifyTipH;
    _notifyImg.frame = CGRectMake(notifyImgX, notifyImgY, notifyImgW, notifyImgH);
}


- (void)bindUIValue2
{
    NSArray *tempArr = [[WFDataBaseManager shareInstance] getAllAnnouncement];
    if ([tempArr count]>0) {
        _announcements = [tempArr mutableCopy];
        [_notifyTip setHidden:YES];
        [_notifyImg setHidden:YES];
        _tableView.backgroundColor = RGB(235, 235, 235);
        [_tableView reloadData];
    }else{
        //提示当前没有公告
        [_notifyTip setHidden:NO];
        [_notifyImg setHidden:NO];
        _tableView.backgroundColor = RGB(255, 255, 255);
    }
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    WFYAnncCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[WFYAnncCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    WFYAnnouncementModel *announcement=[[WFYAnnouncementModel alloc]init];
    announcement=_announcements[indexPath.row];
    cell.announcement = announcement;
    [cell.boxView addClickedBlock:^(id obj) {
        //NSLog(@"我被点击了~");
        WFYAnncWebViewContr *c = [[WFYAnncWebViewContr alloc] init];
        c.announcementId = announcement.announcementId;
        [self.navigationController pushViewController:c animated:YES];
    }];
    __weak typeof(self) _weakself = self;
    [cell.boxView addLongPressBlockWithDuration:1.0f :^(id obj) {
        WFYAnnouncementPopupWindow *vc = [[WFYAnnouncementPopupWindow alloc]init];
        vc.delegate =_weakself;
        vc.indexPath = indexPath;
        vc.announcementId = announcement.announcementId;
        vc.providesPresentationContextTransitionStyle = YES;
        vc.definesPresentationContext = YES;
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:vc animated:NO completion:nil];
        
//        NSArray *menuItems = @[
//
//                               [KxMenuItem menuItem:@"转发                "
//                                              image:nil
//                                             target:self
//                                             action:@selector(pushChat:)],
//                               [KxMenuItem menuItem:@"收藏                "
//                                              image:nil
//                                             target:self
//                                             action:@selector(pushGroupChat:)],
//                               [KxMenuItem menuItem:@"删除                "
//                                              image:nil
//                                             target:self
//                                             action:@selector(delAction:)]
//                               ];
//        CGRect targetFrame = CGRectMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.3, 0, 0);
//        [KxMenu setTintColor:HEXCOLOR(0x000000)];
//        [KxMenu setTitleFont:[UIFont systemFontOfSize:[AppFontMgr standardFontSize]]];
//        [KxMenu showMenuInView:self.navigationController.navigationBar.superview
//                      fromRect:targetFrame
//                     menuItems:menuItems];
    }];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _announcements.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.announcements[indexPath.row].cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)delete:(id)sender{
    
}

#pragma mark - WFYAnnouncementPopupWindowDelegate

//删除后需要更新消息
- (void)deleteAnncMsgClicked:(NSIndexPath *)indexPath{
    [[WFDataBaseManager shareInstance]deleteAnnouncementToDB:_announcements[indexPath.row].announcementId];
    [_announcements removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (_announcements.count>0 && _announcements.count == indexPath.row) { //删除了最后一项
        [WFHTTPTOOL sendAnncMsgWithUserId:kUserId
                           AnnouncementId:[NSString stringWithFormat:@"%ld",(long)_announcements.lastObject.announcementId]
                                 complete:^(BOOL isOK) {
                                     if (isOK) {
                                         WFYLog(@"公告消息发送成功");
                                     }
                                     else{
                                         WFYLog(@"公告消息发送失败");
                                     }
                                 }];
    }else if(_announcements.count==0) {//清空消息
        
    }
    [self bindUIValue2];
}

- (void)tapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
