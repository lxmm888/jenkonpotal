//
//  WFYGroupAnnouncementContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYGroupAnnouncementContr.h"
#import "MBProgressHUD.h"
#import "UIColor+WFColor.h"
#import <RongIMKit/RongIMKit.h>
#import "WFUIBarButtonItem.h"
#import "UITextViewAndPlaceholder.h"

@interface WFYGroupAnnouncementContr ()

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic) CGFloat heigh;

@end

@implementation WFYGroupAnnouncementContr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
    [self bindLeftItem];
    [self bindRightItem];
    [self layoutUI];
}

//自定义leftBarButtonItem
- (void)bindLeftItem
{
    self.leftBtn =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(-6.5, 0, 50, 34)];
    leftLabel.text = @"取消";
    [self.leftBtn addSubview:leftLabel];
    [leftLabel setTextColor:[UIColor whiteColor]];
    [self.leftBtn addTarget:self
                     action:@selector(clickLeftBtn:)
           forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    [self.leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;
}

//自定义rightBarButtonItem
- (void)bindRightItem
{
    self.rightBtn =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 0, 50, 34)];
    self.rightLabel.text = @"完成";
    [self.rightBtn addSubview:self.rightLabel];
    [self.rightBtn addTarget:self
                      action:@selector(clickRightBtn:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    self.rightBtn.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)createUI{
    self.AnnouncementContent = [[UITextViewAndPlaceholder alloc]init];
    [self.view addSubview:self.AnnouncementContent];
}

- (void)bindUIValue{
    self.AnnouncementContent.delegate = self;
    self.AnnouncementContent.font = [UIFont systemFontOfSize:16.f];
    self.AnnouncementContent.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    self.AnnouncementContent.myPlaceholder = @"请编辑群公告";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"群公告";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutUI{
    CGFloat ACX=4.5,ACY=8,ACWidth=SCREEN_WIDTH - 5,ACHeight = SCREEN_HEIGHT - kNaviBarH - 90;
    self.AnnouncementContent.frame = CGRectMake(ACX, ACY, ACWidth, ACHeight);
    self.heigh = ACHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘将要弹出
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.AnnouncementContent.frame;
    frame.origin.y = 8;
    if (frame.size.height == self.heigh) {
        frame.size.height -= keyboardRect.size.height;
        if (frame.size.height != self.heigh) {
            frame.size.height -= 60;
        }
    }
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.AnnouncementContent.frame = frame;
    [UIView commitAnimations];
}

//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //  CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.AnnouncementContent.frame;
    frame.size.height = self.heigh;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.AnnouncementContent.frame = frame;
    [UIView commitAnimations];
}

-(void) navigationButtonIsCanClick:(BOOL)isCanClick
{
    if (isCanClick == NO) {
        self.leftBtn.userInteractionEnabled = NO;
        self.rightBtn.userInteractionEnabled = NO;
    }
    else
    {
        self.leftBtn.userInteractionEnabled = YES;
        self.rightBtn.userInteractionEnabled = YES;
    }
}

-(void)clickLeftBtn:(id)sender
{
    [self navigationButtonIsCanClick:NO];
    if (self.AnnouncementContent.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"退出本次编辑"
                                                       delegate:self
                                              cancelButtonTitle:@"继续编辑"
                                              otherButtonTitles:@"退出",nil];
        alert.tag = 101;
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)clickRightBtn:(id)sender
{
    [self navigationButtonIsCanClick:NO];
    BOOL isEmpty = [self isEmpty:self.AnnouncementContent.text];
    if (isEmpty == YES) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"该公告会通知全部群成员，是否发布？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"发布",nil];
    alert.tag = 102;
    [alert show];
}

//判断内容是否全部为空格  yes 全部为空格  no 不是
- (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return YES;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    NSInteger number = [textView.text length];
    if (number == 0) {
        self.rightBtn.userInteractionEnabled = NO;
        [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    }
    if (number > 0) {
        self.rightBtn.userInteractionEnabled = YES;
        [self.rightLabel setTextColor:[UIColor whiteColor]];
        
        CGRect frame = self.AnnouncementContent.frame;
        
        CGSize maxSize =CGSizeMake(frame.size.width,MAXFLOAT);
        
        CGFloat height = [self.AnnouncementContent.text boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.AnnouncementContent.font} context:nil].size.height;
        frame.size.height = height;
    }
    if (number > 500) {
        textView.text = [textView.text substringToIndex:500];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self navigationButtonIsCanClick:YES];
    switch (alertView.tag) {
        case 101:
        {
            switch (buttonIndex) {
                case 1:
                {
                    _AnnouncementContent.editable = NO;
                    dispatch_after(
                                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                                       [self.navigationController popViewControllerAnimated:YES];
                                   });
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 102:
        {
            switch (buttonIndex) {
                case 1:
                {
                    self.AnnouncementContent.editable = NO;
                    //发布中的时候显示转圈的进度
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    CGPoint point = self.hud.offset;
                    point.y = -46.f;
                    self.hud.offset = point;
                    self.hud.minSize = CGSizeMake(120, 120);
                    self.hud.bezelView.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
                    self.hud.margin = 0;
                    [self.hud setHidden:YES];
                    //发布成功后，使用自定义图片
                    NSString *txt = [NSString stringWithFormat: @"@所有人\n%@",self.AnnouncementContent.text];
                    //去除收尾的空格
                    txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    //去除收尾的换行
                    txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    RCTextMessage *announcementMsg = [RCTextMessage messageWithContent:txt];
                    announcementMsg.mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All userIdList:nil mentionedContent:nil];
                    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
                                          targetId:[NSString stringWithFormat:@"%@",self.GroupId] 
                                           content:announcementMsg
                                       pushContent:nil
                                          pushData:nil
                                           success:^(long messageId) {
                                               dispatch_after(
                                                              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                                                                  self.hud.mode = MBProgressHUDModeCustomView;
                                                                  UIImageView *customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete"]];
                                                                  customView.frame = CGRectMake(0, 0, 80, 80);
                                                                  self.hud.customView = customView;
                                                                  dispatch_after(
                                                                                 dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                                                                                     //显示成功的图片后返回
                                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                                 });
                                                              });
                                           } error:^(RCErrorCode nErrorCode, long messageId) {
                                               [self.hud setHidden:YES];
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                               message:@"群公告发送失败"
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"确定"
                                                                                     otherButtonTitles: nil];
                                               [alert show];
                                           }];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}
@end
