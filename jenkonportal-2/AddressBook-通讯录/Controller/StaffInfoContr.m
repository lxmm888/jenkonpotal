//
//  VipInfoContr.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/18.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "StaffInfoContr.h"
#import "ITDRCell.h"
#import "AppFontMgr.h"
#import "XIMultiBgColorBtn.h"
#import "WFContactSelectedContr.h"
#import "StaffModel.h"
#import "UIImageView+WebCache.h"
#import "DepartmentModel.h"
#import "ChatContr.h"
#import "AppSession.h"
#import "SVProgressHUD.h"
#import <RongCallKit/RongCallKit.h>

@interface StaffInfoContr_infoCell : UIView

@property (weak, nonatomic) UILabel *label;
- (void)layoutUI;

@end

@interface StaffInfoContr ()

@end

@implementation StaffInfoContr
{
    ITDRCell *_header;
    StaffInfoContr_infoCell *_apm;
    StaffInfoContr_infoCell *_pos;
    StaffInfoContr_infoCell *_tel;
    StaffInfoContr_infoCell *_subTel;
    UIButton *_chat;
    UIButton *_audioCallBtn;
    UIButton *_videoCallBtn;
    
    XIMultiBgColorBtn *_groupChat;
    UIButton *_phone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self rebindUIValue];
}

- (void)createGroupChat
{
    WFContactSelectedContr *c = [[WFContactSelectedContr alloc] init];
    c.forCreatingGroup = YES;
    c.isAllowsMultipleSelection = YES;
    c.titleStr = @"选择联系人";
    [self.navigationController pushViewController:c animated:YES];
}

- (void)rebindUIValue
{
    [_header.mImageView sd_setImageWithURL:[NSURL URLWithString:[_staff.avatarUri WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
    _header.mTitleLabel.text = _staff.nickname;
    _header.descLabel.text = _staff.department.name;
    _apm.label.text = [NSString stringWithFormat:@"部门：%@", _staff.department.name];
    self.title= [NSString stringWithFormat:@"%@的资料",_staff.nickname];
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
    [self bindUIValue2];
}

- (void)toChat
{
    [self.view endEditing:YES];
    
    if ([_staff.usrname isEqualToString:[AppSession shareSession].usr.usrname]) {
        [SVProgressHUD showInfoWithStatus:@"不能给自己发消息哦"];
        return;
    }
    ChatContr *chatController = [[ChatContr alloc] initWithConversationType:ConversationType_PRIVATE targetId:_staff.usrname];
    chatController.needPopToRootView = YES;
    chatController.title = _staff.usrname;
    [self.navigationController pushViewController:chatController animated:YES];
}

/**
 *视频通话
 */
- (void)btnVideoCall:(id)sender{
    [[RCCall sharedRCCall] startSingleCall:self.staff.usrname mediaType:RCCallMediaVideo];
}

/**
 *语音通话
 */
- (void)btnAudioCall:(id)sender{
    [[RCCall sharedRCCall] startSingleCall:self.staff.usrname mediaType:RCCallMediaAudio];
}

- (void)createUI
{
    _header = [[ITDRCell alloc] init];
    _apm = [[StaffInfoContr_infoCell alloc] init];
    _pos = [[StaffInfoContr_infoCell alloc] init];
    _tel = [[StaffInfoContr_infoCell alloc] init];
    _subTel = [[StaffInfoContr_infoCell alloc] init];
    _chat = [[UIButton alloc] init];
    _videoCallBtn = [[UIButton alloc] init];
    _audioCallBtn = [[UIButton alloc] init];
    _groupChat = [[XIMultiBgColorBtn alloc] init];
    _phone = [[UIButton alloc] init];
    
    [self.view addSubview:_header];
    [self.view addSubview:_apm];
    [self.view addSubview:_pos];
    [self.view addSubview:_tel];
    [self.view addSubview:_subTel];
    [self.view addSubview:_chat];
    [self.view addSubview:_videoCallBtn];
    [self.view addSubview:_audioCallBtn];
    [_header addSubview:_groupChat];
    [_tel addSubview:_phone];
}

- (void)bindUIValue
{
    self.view.backgroundColor = RGB(245, 245, 245);
    
    _header.mImageView.image = [UIImage imageNamed:@""];
    _header.mTitleLabel.text = @"";
    _header.descLabel.text = @"";
    _header.rightItem.hidden = YES;
    _header.backgroundColor = [UIColor whiteColor];
    
    _apm.backgroundColor = [UIColor whiteColor];
    _apm.label.text = @"部门：";
    
    _pos.backgroundColor = [UIColor whiteColor];
    _pos.label.text = @"职务：";
    
    _tel.backgroundColor = [UIColor whiteColor];
    _tel.label.text = @"电话：";
    
    _subTel.backgroundColor = [UIColor whiteColor];
    _subTel.label.text = @"分机：";
    
    //发消息
    [_chat setImage:[UIImage imageNamed:@"vipInfo_chat_normal"] forState:UIControlStateNormal];
    [_chat setImage:[UIImage imageNamed:@"vipInfo_chat_highlighted"] forState:UIControlStateHighlighted];
    [_chat addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
    //视频
    [_videoCallBtn setImage:[UIImage imageNamed:@"videoCall_normal"] forState:UIControlStateNormal];
    [_videoCallBtn setImage:[UIImage imageNamed:@"videoCall_highlighted"] forState:UIControlStateHighlighted];
    [_videoCallBtn addTarget:self action:@selector(btnVideoCall:) forControlEvents:UIControlEventTouchUpInside];
    //语音
    [_audioCallBtn setImage:[UIImage imageNamed:@"audioCall_normal"] forState:UIControlStateNormal];
    [_audioCallBtn setImage:[UIImage imageNamed:@"audioCall_highlighted"] forState:UIControlStateHighlighted];
    [_audioCallBtn addTarget:self action:@selector(btnAudioCall:) forControlEvents:UIControlEventTouchUpInside];
    
    [_groupChat setTitle:@"发起群聊" forState:UIControlStateNormal];
    _groupChat.titleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+2];
    [_groupChat setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
    _groupChat.layer.borderColor = RGB(236, 236, 236).CGColor;
    _groupChat.layer.borderWidth = 1.0f;
    [_groupChat setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted: RGB(245, 245, 245)];
    [_groupChat addTarget:self action:@selector(createGroupChat) forControlEvents:UIControlEventTouchUpInside];
    
//    _phone.imageView.image = [UIImage imageNamed:@"vipInfo_phone"];
    [_phone setBackgroundImage:[UIImage imageNamed:@"vipInfo_phone"] forState:UIControlStateNormal];
    [_phone addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
//    _phone.image = [UIImage imageNamed:@"vipInfo_phone"];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    
    CGFloat headerTopMargin = 0;//kStatusBarH+kNaviBarH;
    CGFloat headerW = sw, headerH = headerW*0.28, headerX = 0, headerY = headerTopMargin;
    _header.frame = CGRectMake(headerX, headerY, headerW, headerH);
    [_header layoutUI];
    
    // _header ui relayout
    CGFloat rightMv = sw/36;    
    [self rightMv:_header.mImageView :rightMv];
    [self rightMv:_header.mTitleLabel :rightMv];
    [self rightMv:_header.descLabel :rightMv];
    
    CGFloat apmTopMarginToHeader = headerH/7;
    CGFloat cellW = sw, cellH = headerH*0.45, cellX = 0;
    CGFloat apmY = headerY+headerH+apmTopMarginToHeader;
    _apm.frame = CGRectMake(cellX, apmY, cellW, cellH);
    [_apm layoutUI];
    
    CGFloat posY = apmY+cellH;
    _pos.frame = CGRectMake(cellX, posY, cellW, cellH);
    [_pos layoutUI];
    
    CGFloat telY = posY+cellH;
    _tel.frame = CGRectMake(cellX, telY, cellW, cellH);
    [_tel layoutUI];
    
    CGFloat subTelY = telY+cellH;
    _subTel.frame = CGRectMake(cellX, subTelY, cellW, cellH);
    [_subTel layoutUI];
    
    CGFloat chatTopMarginToSubTelBotm = cellH*1.2;
    CGFloat chatW = sw*0.87, chatH = chatW*0.13, chatX = (sw-chatW)/2, chatY = subTelY+cellH+chatTopMarginToSubTelBotm;
    _chat.frame = CGRectMake(chatX, chatY, chatW, chatH);
    
    CGFloat btnTopMarginToBtnBotm = cellH*0.2;
    CGFloat audioCallW = sw*0.87, audioCallH = chatW*0.13,audioCallX =(sw-chatW)/2,audioCallY = CGRectGetMaxY(_chat.frame)+btnTopMarginToBtnBotm;
    _audioCallBtn.frame = CGRectMake(audioCallX, audioCallY, audioCallW, audioCallH);

    CGFloat videoCallW = sw*0.87, videoCallH = chatW*0.13,videoCallX =(sw-chatW)/2,videoCallY = CGRectGetMaxY(_audioCallBtn.frame)+btnTopMarginToBtnBotm;
    _videoCallBtn.frame = CGRectMake(videoCallX, videoCallY, videoCallW, videoCallH);
    
    CGFloat groupChatRightMargin = sw/24;
    CGFloat groupChatH = headerH*0.3, groupChatW = groupChatH*3, groupChatX = headerW-groupChatRightMargin-groupChatW, groupChatY = (headerH-groupChatH)/2;
    _groupChat.frame = CGRectMake(groupChatX, groupChatY, groupChatW, groupChatH);
    
    CGFloat phoneRightMargin = groupChatRightMargin;
    CGFloat phoneH = cellH*0.6, phoneW = phoneH, phoneX = sw-phoneRightMargin-phoneW, phoneY = (cellH-phoneH)/2;
    _phone.frame = CGRectMake(phoneX, phoneY, phoneW, phoneH);
}

- (void)bindUIValue2
{
    _groupChat.layer.cornerRadius = _groupChat.bounds.size.height/2;
}

- (void)rightMv:(UIView *)view :(CGFloat)dis
{
    CGRect frame = view.frame;
    frame.origin.x = frame.origin.x+dis;
    view.frame = frame;
}

- (void)phoneClick
{
//    @"tel://" stringByAppendingString:_staff
//    [NSURL URLWithString:@"tel%@"]
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://10010"]];

    NSLog(@"phoneBtn id clicking");
}

@end


@implementation StaffInfoContr_infoCell
{
    UIView *_line;
}

- (instancetype)init
{
    if (self = [super init]) {
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
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    _label = label;
    
    _line = [[UIView alloc] init];
    [self addSubview:_line];
}

- (void)bindUIValue
{
    _label.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+1];
    
    _line.backgroundColor = RGB(232, 232, 232);
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat labelLeftMargin = w/12;
    CGFloat labelW = w-2*labelLeftMargin, labelH = h, labelX = labelLeftMargin, labelY = 0;
    _label.frame = CGRectMake(labelX, labelY, labelW, labelH);
    
    _line.frame = CGRectMake(0, h-1, w, 1);
}

@end
