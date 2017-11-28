//
//  WFYEditGroupNameContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYEditGroupNameContr.h"
#import "WFUIBarButtonItem.h"
#import "UIColor+WFColor.h"
#import "WFHttpTool.h"
#import <RongIMKit/RongIMKit.h>
#import "WFDataBaseManager.h"
#import "AppConf.h"
#import "AppSession.h"

@interface WFYEditGroupNameContr ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic, strong) WFUIBarButtonItem *rightBtn;

@end

@implementation WFYEditGroupNameContr

+ (instancetype)editGroupNameContr {
    return [[self alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initUI{
    [self creatUI];
    [self bindRightItem];
    [self bindUIValue];
    [self layoutUI];
}

- (void)creatUI{
    self.bgView = [[UIView alloc]init];
    self.groupNameTextField = [[UITextField alloc]init];
    [self.view addSubview:_bgView];
    [self.view addSubview:self.groupNameTextField];
}

//自定义rightBarButtonItem
- (void)bindRightItem
{
    self.rightBtn =
    [[WFUIBarButtonItem alloc]initWithbuttonTitle:@"保存"
                                       titleColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                                      buttonFrame:CGRectMake(0, 0, 50, 30)
                                           target:self
                                           action:@selector(clickDone:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn
                                               setTranslation:self.rightBtn
                                               translation:-11];
}

- (void)bindUIValue{
    _bgView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.groupNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.groupNameTextField.font = [UIFont systemFontOfSize:14];
    self.groupNameTextField.delegate=self;
}

- (void)layoutUI{
    _bgView.frame = CGRectMake(0, 10, SCREEN_WIDTH, 44);
    CGFloat groupNameTextFieldWidth = SCREEN_WIDTH-8-8;
    self.groupNameTextField.frame = CGRectMake(8, 10, groupNameTextFieldWidth, 44);
}

- (void)setGroupInfo:(WFGroupInfo *)groupInfo{
    _groupInfo = groupInfo;
    self.groupNameTextField.text = groupInfo.groupName;
}

- (void)clickDone:(id)sender {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    NSString *nameStr = [_groupNameTextField.text copy];
    nameStr = [nameStr
               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //群组名称需要大于2位
    if ([nameStr length] == 0) {
        [self Alert:@"群组名称不能为空"];
        return;
    }
    //群组名称需要大于2个字
    if ([nameStr length] < 2) {
        [self Alert:@"群组名称过短"];
        return;
    }
    //群组名称需要小于10个字
    if ([nameStr length] > 20) {
        [self Alert:@"群组名称不能超过20个字"];
        return;
    }
    //发送网络请求修改群名称
    NSString *groupIdStr = [NSString stringWithFormat:@"%@",_groupInfo.groupId];
    [WFHTTPTOOL renameGroupWithGroupId:groupIdStr
                            groupName:nameStr
                             complete:^(BOOL result) {
                                 if (result == YES) {
                                     WFGroupInfo *groupInfo = [WFGroupInfo new];
                                     groupInfo.groupId=groupIdStr;
                                     groupInfo.groupName = nameStr;
                                     groupInfo.portraitUri = _groupInfo.portraitUri;                       
                                     [[RCIM sharedRCIM]
                                      refreshGroupInfoCache:groupInfo
                                      withGroupId:groupIdStr];
                                     WFGroupInfo *tempGroupInfo = [[WFDataBaseManager shareInstance]
                                                                   getGroupByGroupId:groupIdStr];
                                     tempGroupInfo.groupName = nameStr;
                                     [[WFDataBaseManager shareInstance]insertGroupToDB:tempGroupInfo];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }
                                 if (result == NO) {
                                     [self Alert:@"群组名称修改不成功"];
                                 }
                             }];
}


- (void)Alert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[UIColor whiteColor]
                      barButtonItem:self.rightBtn];
    return YES;
}


@end
