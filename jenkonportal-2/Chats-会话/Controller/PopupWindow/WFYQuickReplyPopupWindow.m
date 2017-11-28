//
//  WFYQuickReplyPopupWindow.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/30.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYQuickReplyPopupWindow.h"


#define BOTTOM_VIEW_HEIGHT 277

@interface QuickReplyContr_Cell : UITableViewCell

@property (strong,nonatomic) UIView *line;
@property (strong,nonatomic) UILabel *contentLabel;

@end

@implementation QuickReplyContr_Cell

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
    self.line = [[UIView alloc]init];
    self.contentLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.line];
}

- (void)bindUIValue
{
    self.line.backgroundColor = rgba(228, 235, 235, 0.6);
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat contentLeftMargin = w/36;
    CGFloat contentW = w-2*contentLeftMargin, contentH = h*0.9, contentX = contentLeftMargin, contentY = (h-contentH)/2;
    self.contentLabel.frame = CGRectMake(contentX, contentY, contentW, contentH);
    

    CGFloat lineH = 0.5;
    self.line.frame = CGRectMake(0, 0, w, lineH);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

@end

@interface WFYQuickReplyPopupWindow ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *bottomViewHeader;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WFYQuickReplyPopupWindow
{
    CGFloat _cellHeight;
    NSArray *_quickReplyMsgArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIvar];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self layoutUI2];
}

- (void)initIvar
{
    _cellHeight = BOTTOM_VIEW_HEIGHT*0.2;
    //获取快捷回复消息内容
    [self p_getQuickReplyMsg];
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI{
    self.dismissBtn = [[UIButton alloc]init];
    self.bottomView = [[UIView alloc]init];
    self.bottomViewHeader = [[UILabel alloc]init];
    self.tableView = [[UITableView alloc]init];
    
    [self.view addSubview:self.dismissBtn];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.bottomViewHeader];
    [self.bottomView addSubview:self.tableView];
}

- (void)bindUIValue{
    //千万别设置view的alpha 设置alpha 会导致view下的所有子视图都变透明
    self.view.backgroundColor = [UIColor clearColor];
    self.bottomView.backgroundColor = RGB(255, 255, 255);
    self.dismissBtn.backgroundColor = [UIColor blackColor];
    self.dismissBtn.alpha = 0.5f;//设置按钮透明度
    [self.dismissBtn addTarget:self action:@selector(dismissBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomViewHeader setTextAlignment:NSTextAlignmentCenter];
    [self.bottomViewHeader setBackgroundColor:RGB(255, 255, 255)];
    self.bottomViewHeader.text = @"快捷回复";
    self.bottomViewHeader.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1];
    self.bottomViewHeader.textColor = RGB(15, 126, 255);
    
    self.tableView.bounces=NO;
    self.tableView.backgroundColor = RGB(255, 255, 255);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    /** 去除tableview 右侧滚动条 */
    self.tableView.showsVerticalScrollIndicator = NO;
    /** 去掉分割线 */
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)layoutUI{
    self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, BOTTOM_VIEW_HEIGHT);
    self.dismissBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.bottomViewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, _cellHeight);
    
    self.tableView.frame = CGRectMake(0, _cellHeight, SCREEN_WIDTH, BOTTOM_VIEW_HEIGHT-_cellHeight);
}

- (void)layoutUI2{
    //执行动画
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.bottomView.frame;
        rect.origin.y = SCREEN_HEIGHT-rect.size.height;
        self.bottomView.frame=rect;
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)p_getQuickReplyMsg{
    NSString *quickReplyType =[[NSString alloc]init];
    if (_rConversationType == ConversationType_GROUP)
        quickReplyType = @"3";
    else
    if (_rConversationType == ConversationType_PRIVATE){
        //需要判断聊天对象是组织架构成员还是会员
        quickReplyType = @"1";
    };
    [WFHTTPTOOL getQuickReplyMsgByType:quickReplyType
                     successCompletion:^(NSArray *arr) {
                         _quickReplyMsgArr = arr;
                         [_tableView reloadData];
                     }];
}


#pragma mark- 按钮点击事件
//关闭弹窗按钮
- (void) dismissBtn:(UIButton *)btn{
    //执行动画
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.bottomView.frame;
        rect.origin.y = SCREEN_HEIGHT;
        self.bottomView.frame=rect;
        //强制更新约束
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    QuickReplyContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[QuickReplyContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    cell.contentLabel.text = _quickReplyMsgArr[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _quickReplyMsgArr.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissBtn:self.dismissBtn];
    //发送消息
    RCTextMessage *msg = [RCTextMessage messageWithContent:_quickReplyMsgArr[indexPath.row]];
    [[RCIM sharedRCIM] sendMessage:_rConversationType
                          targetId:_sTargetId
                           content:msg
                       pushContent:nil
                          pushData:nil
                           success:^(long messageId) {
                               //
                           }
                             error:^(RCErrorCode nErrorCode, long messageId) {
                                 //
                             }];
}

@end
