//
//  WFYSendCollectionPopupWindow.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYSendCollectionPopupWindow.h"

@interface WFYSendCollectionPopupWindow ()

@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *picView;


@end

@implementation WFYSendCollectionPopupWindow

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI{
    self.dismissBtn = [[UIButton alloc]init];
    self.centerView = [[UIView alloc]init];
    
    [self.view addSubview:self.dismissBtn];
    [self.view addSubview:self.centerView];
}


- (void)bindUIValue{
    //千万别设置view的alpha 设置alpha 会导致view下的所有子视图都变透明
    self.view.backgroundColor = [UIColor clearColor];
    self.centerView.backgroundColor = RGB(255, 255, 255);
    self.dismissBtn.backgroundColor = [UIColor blackColor];
    self.dismissBtn.alpha = 0.5f;//设置按钮透明度
    [self.dismissBtn addTarget:self action:@selector(dismissBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI{
    CGFloat space = SCREEN_WIDTH * 0.1;
    CGFloat centerViewW = SCREEN_WIDTH - 2 * space;
    CGFloat centerViewH = 200;
    self.centerView.frame = CGRectMake(space, (SCREEN_HEIGHT - centerViewH) * 0.5, centerViewW, centerViewH);
    self.dismissBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

#pragma mark- 按钮点击事件
//关闭弹窗按钮
- (void) dismissBtn:(UIButton *)btn{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
