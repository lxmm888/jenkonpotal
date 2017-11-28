//
//  MeContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "MeContr.h"
#import "LoginContr.h"
#import "AppConf.h"
#import "NodeCell.h"
#import "AppSession.h"
#import "XIMultiBgColorBtn.h"
#import "SVProgressHUD.h"
#import "AppConf.h"
#import <RongIMKit/RongIMKit.h>
#import "UIImageView+WebCache.h"

@implementation MeContr
{
    UIImageView *_headerBg;
    UIImageView *_avatar;
    UILabel *_nickname;
    NodeCell *_profile;
    NodeCell *_pwd;
    NodeCell *_setting;
    NodeCell *_feedback;
    
    XIMultiBgColorBtn *_logout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self startOB];
}

- (void)onLogout
{
//    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
//        if (aError==nil) {
//            [[EMClient sharedClient].options setIsAutoLogin:NO];
//
//            // debug
//            [AppSession shareSession].usr = nil;
//            [[AppSession shareSession] updateUsrToDB];
//
//            [self presentViewController:[[LoginContr alloc] init] animated:YES completion:nil];
//        }else {
//            [SVProgressHUD showErrorWithStatus:@"登出失败"];
//        }
//    }];
    
    [[RCIM sharedRCIM] logout];
    
    // debug
    [AppSession shareSession].usr = nil;
    [[AppSession shareSession] updateUsrToDB];

    [self presentViewController:[[LoginContr alloc] init] animated:YES completion:nil];
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self rebindUIValue];
    [self layoutUI];
}

- (void)startOB
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUsrChanged) name:kNotiName_didUsrChanged object:nil];
}

- (void)createUI
{
    _headerBg = [[UIImageView alloc] init];
    _avatar = [[UIImageView alloc] init];
    _nickname = [[UILabel alloc] init];
    _profile = [[NodeCell alloc] init];
    _pwd = [[NodeCell alloc] init];
    _setting = [[NodeCell alloc] init];
    _feedback = [[NodeCell alloc] init];
    _logout = [[XIMultiBgColorBtn alloc] init];
    
    [self.view addSubview:_headerBg];
    [_headerBg addSubview:_avatar];
    [_headerBg addSubview:_nickname];
    [self.view addSubview:_profile];
    [self.view addSubview:_pwd];
    [self.view addSubview:_setting];
    [self.view addSubview:_feedback];
    [_headerBg addSubview:_logout];
}

- (void)bindUIValue
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = RGB(245, 245, 245);
    
    _headerBg.image = [UIImage imageNamed:@"login_header_bg"];
    _headerBg.userInteractionEnabled = YES;
    
    _nickname.textAlignment = NSTextAlignmentCenter;
    _nickname.textColor = [UIColor whiteColor];
    
    UIColor *cellHltColor = RGB(250, 250, 250);
    _profile.mImageView.image = [UIImage imageNamed:@"me_profile"];
    _profile.mTitleLabel.text = @"个人资料";
    [_profile setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    
    _pwd.mImageView.image = [UIImage imageNamed:@"me_pwd"];
    _pwd.mTitleLabel.text = @"修改登录密码";
    [_pwd setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    
    _setting.mImageView.image = [UIImage imageNamed:@"me_setting"];
    _setting.mTitleLabel.text = @"设置";
    [_setting setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    
    _feedback.mImageView.image = [UIImage imageNamed:@"me_feedback"];
    _feedback.mTitleLabel.text = @"意见反馈";
    [_feedback setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    
    [_logout setTitle:@"登出" forState:UIControlStateNormal];
    [_logout setTitleColor:RGB(239, 18, 65) forState:UIControlStateNormal];
    [_logout setBackgroundColorForStateNormal:[UIColor clearColor] hightlighted:[RGB(240, 240, 240) colorWithAlphaComponent:0.5]];
    [_logout addTarget:self action:@selector(onLogout) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat headerBgW = sw, headerBgH = sh*0.4, headerBgX = 0, headerBgY = 0;
    _headerBg.frame = CGRectMake(headerBgX, headerBgY, headerBgW, headerBgH);

    CGFloat avatarH = headerBgH*0.3, avatarW = avatarH;
    _avatar.bounds = CGRectMake(0, 0, avatarW, avatarH);
    _avatar.center = CGPointMake(headerBgW/2, headerBgH*0.45);
    
    CGFloat nicknameTopMarginToAvatarBotm = avatarH/4;
    CGFloat nicknameW = sw, nicknameH = nicknameW*0.1, nicknameX = 0, nicknameY = _avatar.center.y+avatarH/2+nicknameTopMarginToAvatarBotm;
    _nickname.frame = CGRectMake(nicknameX, nicknameY, nicknameW, nicknameH);
    
    CGFloat cellW = sw, cellH = cellW*0.15, cellX = 0;

    CGFloat profileY = headerBgY+headerBgH;
    _profile.frame = CGRectMake(cellX, profileY, cellW, cellH);
    
    CGFloat pwdY = profileY+cellH;
    _pwd.frame = CGRectMake(cellX, pwdY, cellW, cellH);
    
    CGFloat settingY = pwdY+cellH;
    _setting.frame = CGRectMake(cellX, settingY, cellW, cellH);
    
    CGFloat feedback = settingY+cellH;
    _feedback.frame = CGRectMake(cellX, feedback, cellW, cellH);
    
    CGFloat layoutW = avatarW, layoutH = avatarH/2, layoutX = (sw-layoutW)/2, layoutY = nicknameY+nicknameH;
    _logout.frame = CGRectMake(layoutX, layoutY, layoutW, layoutH);
}

- (void)rebindUIValue
{
    UsrModel *usr = [AppSession shareSession].usr;
    _nickname.text = usr.nickname;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:[usr.portraitUri WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
}

- (void)didUsrChanged
{
    [self rebindUIValue];
}

@end
