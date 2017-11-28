//
//  WFAddFriendViewController.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/23.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFAddFriendViewController.h"
#import "ITDRCell.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "DepartmentModel.h"
#import "UIColor+WFColor.h"
#import "WFDataBaseManager.h"
#import "ChatContr.h"
#import "UsrModel.h"

@interface AddFriendContr_Cell : UITableViewCell

@property (weak, nonatomic) ITDRCell *content;

@end

@implementation AddFriendContr_Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
}

- (void)createUI
{
    ITDRCell *content = [[ITDRCell alloc] init];
    _content = content;
    [self.contentView addSubview:_content];
}

- (void)bindUIValue
{
    _content.rightItem.hidden = YES;
    _content.line.hidden = YES;
    _content.userInteractionEnabled = NO;
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat contentLeftMargin = w/36;
    CGFloat contentW = w-2*contentLeftMargin, contentH = h*0.9, contentX = contentLeftMargin, contentY = (h-contentH)/2;
    _content.frame = CGRectMake(contentX, contentY, contentW, contentH);
    [_content layoutUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}


@end


@interface WFAddFriendViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UIButton *addFriendBtn;
@property(nonatomic, strong) UIButton *startChat;

@end

@implementation WFAddFriendViewController
{
    CGFloat _cellHeight;
    UITableView * _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)initIvar{
    _cellHeight=SCREEN_WIDTH * 0.18;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layOutUI];
}

- (void)createUI{
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
}

- (void)bindUIValue{
    self.navigationItem.title =@"添加好友";
    _tableView.backgroundColor = RGB(245, 245, 245);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self setFooterView];
}

- (void)setFooterView{
    UIView *view = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 500)];
    
    self.addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(10,30,SCREEN_WIDTH, 86)];
    [self.addFriendBtn setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
    self.addFriendBtn.layer.masksToBounds = YES;
    self.addFriendBtn.layer.cornerRadius = 5.f;
    [self.addFriendBtn setTitle:@"添加好友" forState:UIControlStateNormal];
    [view addSubview:self.addFriendBtn];
    [self.addFriendBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.addFriendBtn addTarget:self
                          action:@selector(actionAddFriend:)
                forControlEvents:UIControlEventTouchUpInside];
    
    self.startChat = [[UIButton alloc]initWithFrame:CGRectMake(10,30,SCREEN_WIDTH, 86)];
    [self.startChat setTitle:@"发起会话" forState:UIControlStateNormal];
    [self.startChat setTintColor:[UIColor blackColor]];
    [self.startChat setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
    self.startChat.layer.masksToBounds = YES;
    self.startChat.layer.cornerRadius = 5.f;
    
    [view addSubview:self.startChat];
    [self.startChat  setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.startChat addTarget:self
                       action:@selector(actionStartChat:)
             forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.tableFooterView = view;
    
    NSDictionary *views2 = NSDictionaryOfVariableBindings(_addFriendBtn,_startChat);
    //添加约束
    //垂直居中
    [view addConstraint:[NSLayoutConstraint constraintWithItem:_addFriendBtn
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:_startChat
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0]];
    //
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_addFriendBtn]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views2]];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_startChat]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views2]];
    
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_addFriendBtn(43)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views2]];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_startChat(43)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views2]];
    
    NSMutableArray *cacheList =[[NSMutableArray alloc]
                                initWithArray:[[WFDataBaseManager shareInstance]getAllFriends]];
    BOOL isFriend = NO;
    for (UsrModel *tempInfo in cacheList) {
        if ([tempInfo.usrname isEqualToString:self.targetStaffInfo.usrname] &&
            [tempInfo.status isEqualToString:@"20"]) {
            isFriend = YES;
            break;
        }
    }
    if (isFriend ==YES) {
        _addFriendBtn.hidden = YES;
    } else {
        _startChat.hidden = YES;
    }
}



- (void)layOutUI{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    _tableView.frame = CGRectMake(0, 0, sw, sh);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//发送添加好友请求
- (void)actionAddFriend:(id)sender{
    if (_targetStaffInfo) {
        UsrModel *friend = [[WFDataBaseManager shareInstance] getFriendInfo:_targetStaffInfo.usrname];
        
        if (friend && [friend.status isEqualToString:@"10"]) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil
                                                             message:@"已发送好友邀请"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            //发送网络请求
        }
    }
    
    
}

//进入点对点消息页面
- (void)actionStartChart:(id)sender{
    ChatContr *_conversationVC =
    [[ChatContr alloc] init];
    _conversationVC.conversationType = ConversationType_PRIVATE;
    _conversationVC.needPopToRootView = YES;
    _conversationVC.targetId = self.targetStaffInfo.usrname;
    _conversationVC.title = self.targetStaffInfo.nickname;
    _conversationVC.displayUserNameInCell = NO;
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


//由于加好友页面只有一条记录，还可以通过给tableHeaderView赋值的办法来组织好友信息
//通过以下方法组织好友信息的好处是，能保持页面风格一致，同时也回避了布局的麻烦
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    AddFriendContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[AddFriendContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    UIImageView *ivAva =[[UIImageView alloc]init];
    //加载头标
    if ([self.targetStaffInfo.avatarUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:self.targetStaffInfo.usrname
                                 Nickname:self.targetStaffInfo.nickname];
        UIImage *portrait = [defaultPortrait imageFromView];
        ivAva.image = portrait;
    } else {
        [ivAva
         sd_setImageWithURL:[NSURL URLWithString:[self.targetStaffInfo.avatarUri WFYURLString]]
         placeholderImage:[UIImage imageNamed:@"vips_portraitPlaceholder"]];
    }
    cell.content.mImageView.image = ivAva.image;
    cell.content.mTitleLabel.text = _targetStaffInfo.nickname;
    DepartmentModel *dept = [[DepartmentModel alloc] init];
    dept = _targetStaffInfo.department;
    cell.content.descLabel.text = dept.name;
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

//不响应单击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
