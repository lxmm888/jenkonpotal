//
//  LoginContr.m
//  jenkon
//
//  Created by 冯文林  on 17/5/3.
//  Copyright © 2017年 com.huiyang. All rights reserved.
//

#import "LoginContr.h"
#import "XICommonDef.h"
#import "XIMultiBgColorBtn.h"
#import "SVProgressHUD.h"
#import "AppConf.h"
#import "AppSession.h"
#import "UsrModel.h"
#import "AppDelegate.h"
#import "RootContrHelper.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import <RongIMKit/RongIMKit.h>
#import "LoginApi.h"
#import "TokenApi.h"
#import "APPWebMgr.h"
#import "WFHttpTool.h"

@implementation LoginContr
{
    UIImageView *_headerBg;
    UIButton *_back;
    UIImageView *_avatar;
    UIImageView *_phoneImg;
    UIImageView *_lockImg;
    UITextField *_usrname;
    UITextField *_pwd;
    XIMultiBgColorBtn *_signin;
    XIMultiBgColorBtn *_forgetPwd;
    XIMultiBgColorBtn *_signout;
    
    APPWebMgr *_webMgr;
    LoginApi *_api;
    TokenApi *_tkApi;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)initIvar
{
    _webMgr = [APPWebMgr manager];
    
    _api = [[LoginApi alloc] init];
    _api.webDelegate = _webMgr;
    
    _tkApi = [[TokenApi alloc]init];
    _tkApi.webDelegate = _webMgr;
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (![AppSession shareSession].didTabBarContrLaunched) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = [RootContrHelper rootContr];
    }
}

// 注册action
- (void)onRegister
{
    
}

- (NSString *)debug_getToken:(NSString *)usrid
{
    NSDictionary *tokens = @{
                        @"manage1test":@"2PB35LtJHF+7E7sudywMVt4VrJIkaOT++sr3txHcUbqVOzUHn3CHy2maq585cCWBPV7egqwZJdLPIfWpSG/G0o688WUfyyaX",
                        @"manage2test":@"34MPXERrkIqTONhsE6HJLCHcfZWF+Rw4PJSMMJVO+llm2AKWj3NS/wOtaRmLLzFWjp3+K2Rj93QsHY0CkAmtEOIP7habXVAB",
                        @"zhuanjia1test":@"OtVaJ9hNayWE5h2lert8Y+drcdb9wDXPqJU+ZbO1j3JK2i8foR8aVfuhwyPIfJ/rTb6BZsyDBhqp/Up9JbZl7A/3WokzZTKu",
                        
                        @"1":@"IkXNDV0H2RRHtFq9J56TuyHcfZWF+Rw4PJSMMJVO+llm2AKWj3NS/3ICfnI3ZLu6eadmMRR/5WdZ4oGR1Z+5jw==",
                        @"2":@"0T3+SapRZI7QDkgBeqt0XCHcfZWF+Rw4PJSMMJVO+llm2AKWj3NS/1KJEyVhrxyZ3kG+Ts/qG1lZ4oGR1Z+5jw==",
                        @"3":@"HevS0eddGULFW06L1FZSciHcfZWF+Rw4PJSMMJVO+llm2AKWj3NS/+dM5Q82PlqJQB81dyv43NJZ4oGR1Z+5jw=="
                        };
    return tokens[usrid];
}

// 登录action
- (void)onLogin
{
    NSString *usrname = _usrname.text;
    NSString *pwd = _pwd.text;
    __block NSString *nickname = nil;
    __block NSString *portraitUri = nil;
    __block NSString *siteId = nil;//add by zl 20170816 定义一个变量存放所属平台Id，在block中可以修改
    __block NSString *token = nil; //add by zl 20170817 定义一个变量存放用户token，在block中可以修改

    // check params
    BOOL err = NO;
    NSString *errMsg = nil;
    
    if (!usrname.length) {
        err = YES;
        errMsg = @"请输入用户名";
    }else if (!pwd.length) {
        err = YES;
        errMsg = @"请输入密码";
    }
    if (err) {
        [SVProgressHUD showErrorWithStatus:errMsg];
        return;
    }
    
    [SVProgressHUD show];
    
    // 1、用户验证
    _api.usrname = usrname;
    _api.pwd = pwd;
    [_api connect:^(ApiRespModel *resp) {
        
        
    //alter by zl 20170815 接口返回的数据格式发生改变
    /*
     //校验正确时的返回值
     {
     success =     {
     response =         {
     Avatar = "http://www.jenkon.vip";
     DepartmentId = 10;
     Email = "zhaoli@gmail.com";
     NickName = "\U8d75\U7acb";
     SiteId = 1;
     UserID = 45;
     UserName = zhaoli;
     };
     successMessage = "\U767b\U5f55\U6210\U529f";
     successMessageCode = 1;
     };
     }
     //校验出错时的返回值
     {
     error =     {
     errorMessage = "\U7528\U6237\U767b\U5f55\U540d\U79f0\U6216\U7528\U6237\U5bc6\U7801\U4e0d\U6b63\U786e\Uff0c\U8bf7\U91cd\U65b0\U8f93\U5165\U3002";
     errorMessageCode = 2;
     };
     }
     */
    NSLog(@"%@",resp.resultset);
//    NSLog(@"%@",resp.resultset[@"success"][@"response"]);
//    NSLog(@"%@",resp.resultset[@"success"][@"successMessage"]);
//    NSLog(@"%@",resp.resultset[@"success"][@"successMessageCode"]);

        //if ([resp.resultset[0][@"key"] isEqualToString:@"unCorrect"]) {
        if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
            
            //[SVProgressHUD showErrorWithStatus:resp.resultset[0][@"content"]];
            [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
            return;
        }
        // 2、用户验证通过，连接融云server
        else {
            
            //NSDictionary *usrInfo = resp.resultset[0][@"userInfo"];
            NSDictionary *usrInfo = resp.resultset[@"success"][@"response"];
            //获取SiteId值,在获取组织架构时作为参数传入
            siteId=usrInfo[@"SiteId"];
            nickname = usrInfo[@"NickName"];
            portraitUri = [usrInfo[@"Avatar"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            
            // 向app server获取连接融云server所要的token
            // 需要app server向融云server申请token，http://www.rongcloud.cn/docs/ios.html
            // alter by zl 20170817 调用接口服务GetToken来获取Token
            // token 可以保存在应用内
//            NSString *token = [self debug_getToken:usrname];
            
            _tkApi.usrname = usrname;
            [_tkApi connect:^(ApiRespModel *resp) {
                if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
                    [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
                    return;
                } else {
                    NSDictionary *tokenInfo = resp.resultset[@"success"][@"response"];
                    token = tokenInfo[@"token"];
                }
                if (token==nil) {
                    [SVProgressHUD showErrorWithStatus:@"调试模式下不支持该用户"];
                    return;
                }
                // 带上token连接融云server
                [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [融云]登录成功后应设置当前用户，用于SDK显示和发送
                        [RCIM sharedRCIM].currentUserInfo = [[RCUserInfo alloc] initWithUserId:usrname name:nickname portrait:portraitUri];
                        
                        // debug
                        UsrModel *usr = [[UsrModel alloc] init];
                        usr.usrname = usrname;
                        usr.nickname = nickname;
                        usr.siteId = siteId;
                        usr.portraitUri = portraitUri;
                        usr.token = token;
                        [AppSession shareSession].usr = usr;
                        [[AppSession shareSession] updateUsrToDB];
                        
                        [SVProgressHUD dismiss];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_didUsrChanged object:nil];
                        [self back];
                    });
                    
                } error:^(RCConnectErrorCode status) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"错误代码%ld", status]];
                } tokenIncorrect:^{
                    // 正式环境需要留意
                    [SVProgressHUD showErrorWithStatus:@"token非法"];
                }];
                
                //调用接口上传更新registrationID
                NSString *registrationID=[[NSUserDefaults standardUserDefaults]
                                          objectForKey:@"WFYJPushRegistrationID"];
                if (registrationID && registrationID.length>0 ) {
                    [WFHTTPTOOL adminUploadRegistrationID:registrationID
                                                   UserId:usrname
                                                 complete:^(BOOL result) {
                                                     if (result == YES) {
                                                         NSLog(@"上传更新registrationID成功");
                                                     }
                                                     if (result == NO) {
                                                         NSLog(@"上传更新registrationID失败");
                                                     }
                                                 }];
                }
                //同步用户所属群组
                [WFHTTPTOOL syncGroupWithUserId:usrname
                                       complete:^(BOOL result) {
                                           if (result == YES) {
                                               NSLog(@"同步用户所属群组成功");
                                           }
                                           if (result == NO) {
                                               NSLog(@"同步用户所属群组失败");
                                           }
                                       }];
            } :^(NSError *error) {
                XILog(@"%@", error);
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
        
    } :^(NSError *error) {
        XILog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];

}

- (NSString *)sha1Str:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *sha1 = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [sha1 appendFormat:@"%02x", digest[i]];
    }
    return sha1;
}

- (void)initUI
{
    //创建窗体元素
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
    [self bindUIValue2];
}

- (void)createUI
{
    _headerBg = [[UIImageView alloc] init];
    _back = [[UIButton alloc] init];
    _avatar = [[UIImageView alloc] init];
    _phoneImg = [[UIImageView alloc] init];
    _lockImg = [[UIImageView alloc] init];
    _usrname = [[UITextField alloc] init];
    _pwd = [[UITextField alloc] init];
    _signin = [[XIMultiBgColorBtn alloc] init];
    _forgetPwd = [[XIMultiBgColorBtn alloc] init];
    _signout = [[XIMultiBgColorBtn alloc] init];
    
    [self.view addSubview:_headerBg];
    [_headerBg addSubview:_back];
    [_headerBg addSubview:_avatar];
    [self.view addSubview:_phoneImg];
    [self.view addSubview:_lockImg];
    [self.view addSubview:_usrname];
    [self.view addSubview:_pwd];
    [self.view addSubview:_signin];
    [self.view addSubview:_forgetPwd];
    [self.view addSubview:_signout];
}

- (void)bindUIValue
{
    // show navi bar
    self.title = @"登录";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // self.view
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tap];
    self.view.userInteractionEnabled = YES;
    
    _headerBg.image = [UIImage imageNamed:@"login_header_bg"];
    _headerBg.userInteractionEnabled = YES;
    
    // 不启用
    _back.hidden = YES;
    [_back setImage:[UIImage imageNamed:@"common_leftback"] forState:UIControlStateNormal];
    [_back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    _avatar.image = [UIImage imageNamed:@"login_header_avatarPlaceholder"];
    
    _phoneImg.image = [UIImage imageNamed:@"login_body_phone"];
    
    _lockImg.image = [UIImage imageNamed:@"login_body_lock"];
    
    _usrname.placeholder = @"用户名";
    
    _pwd.placeholder = @"密码";
    [_pwd setSecureTextEntry:YES];//密码框显示圆星号
    
    [_signin setBackgroundColorForStateNormal:rgba(0, 90, 119, 1) hightlighted:rgba(0, 61, 82, 1)];
    [_signin setTitle:@"登录" forState:UIControlStateNormal];
    [_signin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_signin addTarget:self action:@selector(onLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [_forgetPwd setBackgroundColorForStateNormal:[UIColor clearColor] hightlighted:rgba(227, 227, 227, 1)];
    _forgetPwd.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [_forgetPwd setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [_forgetPwd setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    // 不启用
    _signout.hidden = YES;
    [_signout setTitle:@"登出" forState:UIControlStateNormal];
    [_signout setTitleColor:rgba(239, 18, 65, 1) forState:UIControlStateNormal];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat headerBgTopMargin = 0;
    CGFloat headerBgW = sw, headerBgH = sh*0.3, headerBgX = 0, headerBgY = headerBgTopMargin;
    _headerBg.frame = CGRectMake(headerBgX, headerBgY, headerBgW, headerBgH);
    
    CGFloat backLeftMargin = sw/24;
    CGFloat backH = headerBgH/5, backW = backH, backX = backLeftMargin, backY = kStatusBarH+backLeftMargin*0.6;
    _back.frame = CGRectMake(backX, backY, backW, backH);
    
    CGFloat avatarH = headerBgH*0.4, avatarW = avatarH;
    _avatar.bounds = CGRectMake(0, 0, avatarW, avatarH);
    _avatar.center = CGPointMake(headerBgW/2, headerBgH/2);
    
    CGFloat phoneLeftMargin = sw/12, phoneTopMarginToHeaderBgBotm = phoneLeftMargin/2;
    CGFloat phoneW = sw/12, phoneH = phoneW, phoneX = phoneLeftMargin, phoneY = headerBgY+headerBgH+phoneTopMarginToHeaderBgBotm;
    _phoneImg.frame = CGRectMake(phoneX, phoneY, phoneW, phoneH);
    
    CGFloat usrnameLeftMarginToPhoneRgiht = phoneLeftMargin*1.5;
    CGFloat usrnameW = sw*0.5;
    CGFloat usrnameH = phoneH;
    CGFloat usrnameX = phoneX+phoneW+usrnameLeftMarginToPhoneRgiht;
    CGFloat usrnameY = phoneY;
    _usrname.frame = CGRectMake(usrnameX, usrnameY, usrnameW, usrnameH);
    
    CGFloat lockTopMarginToPhoneBotm = phoneTopMarginToHeaderBgBotm;
    CGFloat lockW = phoneW, lockH = lockW, lockX = phoneX, lockY = phoneY+phoneH+lockTopMarginToPhoneBotm;
    _lockImg.frame = CGRectMake(lockX, lockY, lockW, lockH);
    
    CGFloat pwdTopMarginToUsrnameBotm = lockTopMarginToPhoneBotm;
    CGFloat pwdW = usrnameW;
    CGFloat pwdH = usrnameH;
    CGFloat pwdX = usrnameX;
    CGFloat pwdY = usrnameY+usrnameH+pwdTopMarginToUsrnameBotm;
    _pwd.frame = CGRectMake(pwdX, pwdY, pwdW, pwdH);
    
    CGFloat signinTopMarginToPwdBotm = pwdTopMarginToUsrnameBotm*2;
    CGFloat signinW = sw*0.8;
    CGFloat signinH = signinW*0.15;
    CGFloat signinX = (sw-signinW)/2;
    CGFloat signinY = pwdY+pwdH+signinTopMarginToPwdBotm;
    _signin.frame = CGRectMake(signinX, signinY, signinW, signinH);
    
    CGFloat forgetPwdTopMarginToSigninBotm = signinTopMarginToPwdBotm*0.3;
    CGFloat forgetPwdW = signinW;
    CGFloat forgetPwdH = signinH;
    CGFloat forgetPwdX = (sw-forgetPwdW)/2;
    CGFloat forgetPwdY = signinY+signinH+forgetPwdTopMarginToSigninBotm;
    _forgetPwd.frame = CGRectMake(forgetPwdX, forgetPwdY, forgetPwdW, forgetPwdH);
    
    CGFloat signoutBotmMarginToSignupBotm = sh*0.05;
    CGFloat signoutW = forgetPwdW;
    CGFloat signoutH = forgetPwdH;
    CGFloat signoutX = forgetPwdX;
    CGFloat signoutY = sh-signinH-signoutBotmMarginToSignupBotm;
    _signout.frame = CGRectMake(signoutX, signoutY, signoutW, signoutH);

}

- (void)bindUIValue2
{
    _signin.layer.masksToBounds = YES;
    _signin.layer.cornerRadius = _signin.bounds.size.height/2;
}

@end
