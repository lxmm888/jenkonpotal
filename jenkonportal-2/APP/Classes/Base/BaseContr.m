//
//  BaseContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseContr.h"

@implementation BaseContr

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

- (void)initIvar
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tap];
    self.view.userInteractionEnabled = YES;
}

- (void)initUI
{
    
}

- (void)createUI
{
    
}

- (void)bindUIValue
{
    
}

- (void)layoutUI
{
    
}

// layout之后再绑定的参数
- (void)bindUIValue2
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
