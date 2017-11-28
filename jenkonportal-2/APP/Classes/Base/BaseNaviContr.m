//
//  BaseNaviContr.m
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/10.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "BaseNaviContr.h"
#import "XICommonDef.h"

@interface BaseNaviContr ()

@end

@implementation BaseNaviContr

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI
{
    [self bindUIValue];
}

- (void)bindUIValue
{
    // navi bar 风格
    self.navigationBar.barTintColor = RGB(0, 90, 119);
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

// override
// 非根控制器push时隐藏tabBar
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //使用自定义的导航栏控制器，重写pushViewController方法，可以捕获每一个push进来的控制器，然后进行统一的设计
    if (self.childViewControllers.count>0) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 6, 87, 23);
        UIImageView *backImg = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"navi_back"]];
        backImg.frame = CGRectMake(-6, 4, 10, 17);//4 -> 8
        [backBtn addSubview:backImg];
        UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];//4 -> 8
        [backText setBackgroundColor:[UIColor clearColor]];
        [backText setTextColor:[UIColor whiteColor]];
        [backBtn addSubview:backText];
        [backBtn addTarget:self
                    action:@selector(tapBack:)
          forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:backBtn];
        //隐藏底部导航栏
        viewController.hidesBottomBarWhenPushed = YES;
    }else {
        viewController.hidesBottomBarWhenPushed = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)tapBack:(id)sender
{
    [self popViewControllerAnimated:YES];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

@end
