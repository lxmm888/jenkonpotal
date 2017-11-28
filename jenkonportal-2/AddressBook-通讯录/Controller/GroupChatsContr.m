//
//  GroupChatsContr.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "GroupChatsContr.h"
#import "AppFontMgr.h"
#import "GroupChatsHelper.h"
#import "WFUIBarButtonItem.h"
#import "WFContactSelectedContr.h"
#import "XIMultiBgColorBtn.h"
#import "ITDRCell.h"
#import "WFDataBaseManager.h"
#import "WFGroupInfo.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "ChatContr.h"
#import "SVProgressHUD.h"
#import "AppSession.h"
#import "WFHttpTool.h"

@interface GroupChatsContr_Cell : UITableViewCell

/** 注释 */
@property (nonatomic, weak) ITDRCell *content;

@end

@implementation GroupChatsContr_Cell


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
}

- (void)createUI{
    ITDRCell *content = [[ITDRCell alloc]init];
    _content = content;
    [self.contentView addSubview:_content];
    
}

- (void)bindUIValue{
    _content.line.hidden = YES;
    _content.userInteractionEnabled =NO;
}

- (void) layoutUI{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat contentLeftMargin = w/36;
    CGFloat contentW = w-2*contentLeftMargin, contentH = h*0.9, contentX = contentLeftMargin, contentY = (h-contentH)/2;
    _content.frame = CGRectMake(contentX, contentY, contentW, contentH);
    [_content layoutUI];
}

- (void) layoutSubviews{
    [super layoutSubviews];
    [self layoutUI];
}
@end

@interface GroupChatsContr ()<UITableViewDataSource, UITableViewDelegate>

/** 当前用户所在的所有群组信息 */
@property(nonatomic, strong) NSMutableArray *groups;

@end

@implementation GroupChatsContr
{
    UIView *_tbHeader;
    UILabel *_tbHeaderTitle;
    UITableView *_tbGroups;
    XIMultiBgColorBtn *_creatGroup;
    UILabel * _createGroupTip;
    CGFloat _cellHeight;
//    APPWebMgr *_webMgr;
//    BaseApi *_myGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
//    [[GroupChatsHelper shareHelper] savaGroupChat:@"manage1test" :@"1"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self bindUIValue2];
}

- (void)initUI
{
    [self initIvar];
    [self createUI];
    //自定义rightBarButtonItem
    [self bindRightItem];
    [self bindUIValue];
    [self layoutUI];
}

- (void)initIvar
{
    _cellHeight = SCREEN_WIDTH*0.18;
//    _webMgr = [[APPWebMgr alloc]init];
//    _myGroup = [BaseApi WebRequestApiWithType:WebRequestApiTypeMyGroup];
//    _myGroup.webDelegate = _webMgr;
}

- (void)createUI
{
    _tbHeader = [[UIView alloc] init];
    _tbHeaderTitle = [[UILabel alloc] init];
    _tbGroups = [[UITableView alloc] init];
    
    _createGroupTip = [[UILabel alloc]init];
    _creatGroup = [[XIMultiBgColorBtn alloc]init];
    
    [_tbHeader addSubview:_tbHeaderTitle];
    [self.view addSubview:_tbGroups];
    [self.view addSubview:_creatGroup];
    [self.view addSubview:_createGroupTip];
}

//自定义rightBarButtonItem
- (void)bindRightItem
{
    WFUIBarButtonItem *rightBtn=
    [[WFUIBarButtonItem alloc]initContainImage:[UIImage imageNamed:@"add"]
                                imageViewFrame:CGRectMake(0, 0, 17, 17)
                                   buttonTitle:nil
                                    titleColor:nil
                                    titleFrame:CGRectZero
                                   buttonFrame:CGRectMake(0, 0, 17, 17)
                                        target:self
                                        action:@selector(pushCreateGroupChat:)];
    self.navigationItem.rightBarButtonItems = [rightBtn setTranslation:rightBtn translation:-6];
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

- (void)bindUIValue
{
    self.title = @"群聊";
    self.view.backgroundColor = RGB(245, 245, 245);
    
    _tbHeader.backgroundColor = RGB(245, 245, 245);
    
    _tbHeaderTitle.textColor = RGB(102, 102, 102);
    _tbHeaderTitle.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1];
    _tbHeaderTitle.text = @"我加入的群";
    [_tbHeaderTitle setHidden:YES];
    
    [_creatGroup setBackgroundColorForStateNormal:rgba(0, 90, 119, 1) hightlighted:rgba(0, 61, 82, 1)];
    [_creatGroup setTitle:@"创建群聊" forState:UIControlStateNormal];
    _creatGroup.titleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+2];
    [_creatGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_creatGroup addTarget:self
                    action:@selector(pushCreateGroupChat:)
          forControlEvents:UIControlEventTouchUpInside];
    [_creatGroup setHidden:YES];
    
    _createGroupTip.text = @"你还没有群聊,创建一个吧！";
    _createGroupTip.textColor = RGB(102, 102, 102);
    _createGroupTip.textAlignment =NSTextAlignmentCenter;
    _createGroupTip.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
    [_createGroupTip setHidden:YES];
    
    _tbGroups.userInteractionEnabled=YES;
//    _tbGroups.tableHeaderView = _tbHeader;
    _tbGroups.tableFooterView = [[UIView alloc] init];
    _tbGroups.dataSource = self;
    _tbGroups.delegate = self;
}

//- viewfor

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat tbHeaderW = sw, tbHeaderH = tbHeaderW*0.1;
    _tbHeader.frame = CGRectMake(0, 0, tbHeaderW, tbHeaderH);
    _tbGroups.tableHeaderView = _tbHeader;

    CGFloat tbHeaderTitleX= sw *0.05;
    CGFloat tbHeaderTitleH= tbHeaderTitleX;
    CGFloat tbHeaderTitleY= tbHeaderH /2.0 - tbHeaderTitleH /2.0;
    CGFloat tbHeaderTitleW= sw * 0.3;
    
    _tbHeaderTitle.frame = CGRectMake(tbHeaderTitleX, tbHeaderTitleY, tbHeaderTitleW, tbHeaderTitleH);
    
    CGFloat groupTopMargin = kStatusBarH+kNaviBarH;
    CGFloat groupW = sw, groupH = sh-groupTopMargin, groupX = 0, groupY = 0;
    _tbGroups.frame = CGRectMake(groupX, groupY, groupW, groupH);
    

    CGFloat creatGroupW = sw*0.5;
    CGFloat creatGroupH = creatGroupW*0.22;
    CGFloat creatGroupX = (sw-creatGroupW)/2.0;
    CGFloat creatGroupY = (sh-groupTopMargin-creatGroupH)/2.0;
    _creatGroup.frame = CGRectMake(creatGroupX, creatGroupY, creatGroupW, creatGroupH);
    
    CGFloat creatGroupTipW = sw*0.5;
    CGFloat creatGroupTipH = creatGroupW*0.05;
    CGFloat creatGroupTipX = (sw-creatGroupW)/2.0;
    CGFloat creatGroupTipY = creatGroupY-creatGroupH;
    _createGroupTip.frame = CGRectMake(creatGroupTipX, creatGroupTipY, creatGroupTipW, creatGroupTipH);
}

- (void)bindUIValue2
{
    _creatGroup.layer.masksToBounds = YES;
    _creatGroup.layer.cornerRadius = _creatGroup.bounds.size.height/6;
    // 发送网络请求，获取当前用户所在的所有群组信息，同时更新到本地数据库
    [[WFHttpTool shareInstance] getMyGroupsWithBlock:^(NSMutableArray *result) {
        if (result.count>0) {
            dispatch_async(
               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                   NSMutableArray *tempGroups = [NSMutableArray
                                                 arrayWithArray:[[WFDataBaseManager shareInstance] getAllGroup]];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       _groups = tempGroups;
                       if ([_groups count] > 0) {
                           _creatGroup.hidden = YES;
                           _createGroupTip.hidden = YES;
                           _tbHeaderTitle.hidden = NO;
                           _tbHeaderTitle.text = [NSString stringWithFormat:@"我加入的群（%lu)",[_groups count]];
                           [_tbGroups reloadData];
                       }
                       else{
                           _creatGroup.hidden = NO;
                           _createGroupTip.hidden = NO;
                           _tbHeaderTitle.hidden = YES;
                       }
                       [_tbGroups reloadData];
                   });
               });
        }else{
            _creatGroup.hidden = NO;
            _createGroupTip.hidden = NO;
            _tbHeaderTitle.hidden = YES;
        }
    }];
}

#pragma mark - UITableViewDataSource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    GroupChatsContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[GroupChatsContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    WFGroupInfo *groupInfo=_groups[indexPath.row];
    cell.content.mTitleLabel.text = groupInfo.groupName;
    //显示群备注前，也许需要请求服务获取创建者的备注姓名
    cell.content.descLabel.text = [NSString stringWithFormat:@"创建者：%@ 群人数：%@",groupInfo.creatorId,groupInfo.number];
    if ([groupInfo.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:[NSString stringWithFormat:@"%@",groupInfo.groupId]
                                 Nickname:groupInfo.groupName];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.content.mImageView.image = portrait;
    } else {
        [cell.content.mImageView
         sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portraitUri WFYURLString]]
         placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    cell.content.mImageView.layer.masksToBounds = YES;
    cell.content.mImageView.layer.cornerRadius = cell.bounds.size.height*0.9/2.0;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WFGroupInfo *groupInfo=_groups[indexPath.row];
    ChatContr *chatVC = [[ChatContr alloc] init];
    chatVC.needPopToRootView = YES;
    chatVC.targetId = [NSString stringWithFormat:@"%@",groupInfo.groupId];
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.title = [NSString stringWithFormat:@"%@(%@)",groupInfo.groupName,groupInfo.number];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatVC animated:YES];
    });
}


@end
