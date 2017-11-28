//
//  CreateGroupContr.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/25.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "CreateGroupContr.h"
#import <RongIMKit/RongIMKit.h>
#import "MBProgressHUD.h"
#import "UIColor+WFColor.h"
#import "BaseApi.h"
#import "APPWebMgr.h"
#import "SVProgressHUD.h"
#import "ChatContr.h"
#import "DefaultPortraitView.h"
#import "WFDataBaseManager.h"
#import "WFGroupInfo.h"
#import "StaffModel.h"
#import "WFHttpTool.h"

// 是否iPhone5
#define isiPhone5                                                              \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(640, 1136),                              \
                           [[UIScreen mainScreen] currentMode].size)           \
        : NO)
// 是否iPhone4
#define isiPhone4                                                              \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(640, 960),                               \
                           [[UIScreen mainScreen] currentMode].size)           \
        : NO)



@interface CreateGroupContr ()
{
    NSData *data;
    UIImage *image;
    MBProgressHUD *hud;
    CGFloat defaultY;
    APPWebMgr *_webMgr;
    BaseApi *_groupApi;
//    CreatGroupApi *_groupApi;
}

@property (nonatomic, strong) UIImageView *GroupPortrait;
@property (nonatomic, strong) UITextField *GroupName;
@property (nonatomic,strong) UIView *blueLine;

@end

@implementation CreateGroupContr

+ (instancetype)createGroupViewController {
    return [[[self class] alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    [self initIvar];
    [self createUI];
    //自定义rightBarButtonItem
    [self bindUIValue];
    [self layoutUI];
}

- (void)initIvar
{
//    _webMgr = [APPWebMgr manager];
//    //以“类族模式”隐藏实现细节
//    _groupApi= [BaseApi WebRequestApiWithType:WebRequestApiTypeCreatGroup];
////    _groupApi = [[CreatGroupApi alloc]init];
//    _groupApi.webDelegate= _webMgr;
}

- (void)createUI
{
    //群组头像的UIImageView
    self.GroupPortrait = [[UIImageView alloc]init];
    //群组名称的UITextField
    self.GroupName = [[UITextField alloc]init];
    //底部蓝线
    self.blueLine = [[UIView alloc]init];
    
    [self.view addSubview:self.GroupPortrait];
    [self.view addSubview:self.GroupName];
    [self.view addSubview:self.blueLine];
    
    [self bindRightItem];
}

- (void)bindRightItem
{
    UIBarButtonItem *item =
    [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(ClickDoneBtn:)];
    item.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;//SDK中全局的导航按钮字体颜色
    self.navigationItem.rightBarButtonItem = item;
}

- (void)bindUIValue
{
    self.view.backgroundColor =[UIColor whiteColor];
    
    self.GroupPortrait.image = [UIImage imageNamed:@"AddPhotoDefault"];
    // 出现圆角效果
    self.GroupPortrait.layer.masksToBounds = YES;
    self.GroupPortrait.layer.cornerRadius =5.f;
    // 为图像设置点击事件
    self.GroupPortrait.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleClick=
    [[UITapGestureRecognizer alloc]initWithTarget:self
                                           action:@selector(chosePortrait)];
    [self.GroupPortrait addGestureRecognizer:singleClick];
    
    self.GroupName.font = [UIFont systemFontOfSize:14];
    self.GroupName.placeholder = @"填写群名称（2-10个字符）";
    self.GroupName.textAlignment = NSTextAlignmentCenter;
    self.GroupName.delegate = self;
    self.GroupName.returnKeyType = UIReturnKeyDone;
    
    self.blueLine.backgroundColor = [UIColor colorWithRed:0 green:135/255.0 blue:251/255.0 alpha:1];
    
    //给整个view添加手势，隐藏键盘
    UITapGestureRecognizer *resetBottomTapGesture =
    [[UITapGestureRecognizer alloc]initWithTarget:self
                                           action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:resetBottomTapGesture];
    
    defaultY = kStatusBarH+kNaviBarH;
}

- (void)layoutUI
{
    CGFloat groupPotraitWidth = 100;
    CGFloat groupPortraitHeight = groupPotraitWidth;
    CGFloat groupPortraitX = SCREEN_WIDTH/2.0 -groupPotraitWidth/2.0;
    CGFloat groupPortraitY = 80;
    self.GroupPortrait.frame = CGRectMake(groupPortraitX, groupPortraitY, groupPotraitWidth, groupPortraitHeight);
    
    CGFloat groupNameWidth = 200;
    CGFloat groupNameHeigth = 17;
    CGFloat groupNameX = SCREEN_WIDTH/2.0 - groupNameWidth/2.0;
    CGFloat GroupNameY = CGRectGetMaxY(self.GroupPortrait.frame)+120;
    self.GroupName.frame = CGRectMake(groupNameX, GroupNameY, groupNameWidth, groupNameHeigth);
    
    CGFloat blueLineWidth = 240;
    CGFloat blueLineHeigth = 1;
    CGFloat blueLineX = SCREEN_WIDTH/2.0 - blueLineWidth/2.0;
    CGFloat blueLineY = CGRectGetMaxY(self.GroupName.frame)+1;
    self.blueLine.frame = CGRectMake(blueLineX, blueLineY, blueLineWidth, blueLineHeigth);
}

// layout之后再绑定的参数
- (void)bindUIValue2
{
    
}

// 选择头像
- (void)chosePortrait{
    //还原屏幕位置
    [self moveView:defaultY];
    [_GroupName resignFirstResponder];
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc]initWithTitle:nil
                                   delegate:self
                          cancelButtonTitle:@"取消"
                     destructiveButtonTitle:@"拍照"
                          otherButtonTitles:@"我的相册", nil ];
    [actionSheet showInView:self.view];
}

// 隐藏键盘
- (void)hideKeyboard:(id)sender{
    [self moveView:defaultY];
    [_GroupName resignFirstResponder];
}

// 点击完成按钮
- (void)ClickDoneBtn:(id)sender{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self moveView:defaultY];
    [_GroupName resignFirstResponder];
    
    NSString *nameStr = [self.GroupName.text copy];
    nameStr = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //群组名称需要大于2个字
    if ([nameStr length] == 0) {
        [self Alert:@"群组名称不能为空"];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    //群组名称需要小于10个字
    else if ([nameStr length] > 20){
        [self Alert:@"群组名称不能超过20个字"];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        //alter 20170905 创建群接口已经修改，不用单独处理群主
//        BOOL isAddedcurrentUserID = false;
//        for (NSString *userId in _GroupMemberIdList) {
//            if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
//                isAddedcurrentUserID = YES;
//            } else {
//                isAddedcurrentUserID = NO;
//            };
//        }
//        if (isAddedcurrentUserID == NO) {
//            [_GroupMemberIdList addObject:[RCIM sharedRCIM].currentUserInfo.userId];
//        }
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
        hud.label.text =@"创建中";
        [hud showAnimated:YES];
        
        //发送网络请求，请求服务器接口CreateChatGroup
        [WFHTTPTOOL createGroupWithGroupName:nameStr
                             GroupMemberList:_GroupMemberIdList
                                    complete:^(NSString * groupId) {
                                        if (groupId) {
                                            NSString *groupIdStr = [NSString stringWithFormat:@"%@",groupId];
                                            [WFHTTPTOOL getGroupMembersWithGroupId:groupIdStr
                                                                              Block:^(NSMutableArray *result) {
                                                                                  //更新本地数据库中群组成员的信息
                                                                              }];
                                            if (image != nil) {
                                                //上传头像和头像地址
                                                XILog(@"创建群组成功后上传头像和头像地址,待完成。。。");
                                            }else{
                                                [hud hideAnimated:YES];
                                                RCGroup *groupInfo = [RCGroup new];
                                                groupInfo.groupId=groupIdStr;
                                                groupInfo.groupName = nameStr;
                                                groupInfo.portraitUri=[self createDefaultPortrait:[NSString stringWithFormat:@"%@", groupIdStr]
                                                                                        GroupName:nameStr];
                                                [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo
                                                                             withGroupId:groupIdStr];
                                                //调用接口根据id获取单个群组，返回群组的详细信息
                                                [WFHTTPTOOL getGroupByID:groupInfo.groupId
                                                       successCompletion:^(WFGroupInfo *group) {
                                                           [[WFDataBaseManager shareInstance]insertGroupToDB:group];
                                                       }];
                                                [self gotoChatView:groupId groupName:nameStr];
                                            }
                                        }
                                        else{
                                            [hud setHidden:YES];
                                            self.navigationItem.rightBarButtonItem.enabled =YES;
                                            [self Alert:@"创建群组失败，请检查你的网络设置。"];
                                        }
                                    }];
//        NSMutableDictionary *userIdList= [@{} mutableCopy];
//        [_GroupMemberIdList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [userIdList setObject:obj forKey:[NSString stringWithFormat:@"user%lu",idx+1]];
//        }];
//        NSMutableArray *userList =[@[] mutableCopy];
//        for (StaffModel *staff in _GroupMemberList) {
//            RCUserInfo *user = [[RCUserInfo alloc]init];
//            user.userId = staff.usrname;
//            user.name = staff.nickname;
//            user.portraitUri = staff.avatarUri;
//            [userList addObject:user];
//        }
//        _groupApi.inputParams = @{
//                     @"userId":[RCIM sharedRCIM].currentUserInfo.userId,
//                     @"userIdList":[self dictionaryToJson:userIdList],
//                     @"groupName":nameStr
//                     };
//        [_groupApi connect:^(ApiRespModel *resp) {
//            if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
//                [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
//                return;
//            }
//            //创建群组成功
//            //群组创建成功后需要接口提供上传头像的功能
//            if (image != nil) {
//              //需要将头像上传到网上，获取返回的头像地址
//                
//            }else{
//                NSDictionary *resultInfo = resp.resultset[@"success"][@"response"];
//                NSString *groupId =resultInfo[@"ChatGroupId"];
//                [hud hideAnimated:YES];
//                RCGroup *groupInfo = [RCGroup new];
//                groupInfo.groupId=groupId;
//                groupInfo.groupName = nameStr;
//                groupInfo.portraitUri=[self createDefaultPortrait:groupId GroupName:nameStr];
//                [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo
//                                             withGroupId:groupId];
//                //调用接口根据id获取单个群组，返回群组的详细信息
//                [WFHTTPTOOL getGroupByID:groupInfo.groupId
//                       successCompletion:^(WFGroupInfo *group) {
//                           [[WFDataBaseManager shareInstance]insertGroupToDB:group];
//                       }];
//                [self gotoChatView:groupId groupName:nameStr];
//            }
//        } :^(NSError *error) {
//            [hud hideAnimated:YES];
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//            XILog(@"%@", error);
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//        }];
    }
}

- (void)gotoChatView:(NSString *)groupId groupName:(NSString *)groupName{
    ChatContr *chatVC = [[ChatContr alloc] init];
    chatVC.needPopToRootView = YES;
    chatVC.targetId = [NSString stringWithFormat:@"%@",groupId];
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.title = [NSString stringWithFormat:@"%@(%lu)",groupName,_GroupMemberIdList.count];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatVC animated:YES];
    });
}

//字典转json格式字符串：
- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)Alert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//移动屏幕
- (void)moveView:(CGFloat)Y{
    [UIView beginAnimations:nil context:nil];
    self.view.frame =
        CGRectMake(0, Y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (NSString *)createDefaultPortrait:(NSString *)groupId
                          GroupName:(NSString *)groupName {
    DefaultPortraitView *defaultPortrait =
    [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:groupId Nickname:groupName];
    UIImage *portrait = [defaultPortrait imageFromView];
    
    NSString *filePath = [self
                          getIconCachePath:[NSString stringWithFormat:@"group%@.png", groupId]];
    
    BOOL result =
    [UIImagePNGRepresentation(portrait) writeToFile:filePath atomically:YES];
    if (result == YES) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    }
    return nil;
}

- (NSString *)getIconCachePath:(NSString *)fileName {
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(
                                                              NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =
    [cachPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"CachedIcons/%@",
      fileName]]; // 保存文件的名称
    
    NSString *dirPath = [cachPath
                         stringByAppendingPathComponent:[NSString
                                                         stringWithFormat:@"CachedIcons"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return filePath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (isiPhone5) {
        [self moveView:-40];
    }
    if (isiPhone4) {
        [self moveView:-80];
    }
    //ipone 6 6s plus...
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [_GroupName resignFirstResponder];
    [self moveView:defaultY];
    return YES;
}



#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate =self;
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                NSLog(@"模拟器无法连接相机");
            }
            [self presentViewController:picker animated:YES completion:nil];
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        UIImage *captureImage = [self getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        
        UIImage *scaleImage = [self scaleImage:captureImage toScale:0.8];
        data = UIImageJPEGRepresentation(scaleImage, 0.00001);
        
    }
    
    image = [UIImage imageWithData:data];
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.GroupPortrait.image = image;
    });
}

-(UIImage*)getSubImage:(UIImage *)originImage Rect:(CGRect)rect imageOrientation:(UIImageOrientation)imageOrientation
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(originImage.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:1.f orientation:imageOrientation];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}

- (UIImage *)scaleImage:(UIImage *)Image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(
                                CGSizeMake(Image.size.width * scaleSize, Image.size.height * scaleSize));
    [Image drawInRect:CGRectMake(0, 0, Image.size.width * scaleSize,
                                 Image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
