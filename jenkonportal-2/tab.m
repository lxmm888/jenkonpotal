//
//  tab.m
//  jenkonportal
//
//  Created by Xuan on 2017/11/24.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "tab.h"
#import "testViewController.h"

@interface tab ()

@end

@implementation tab

- (void)viewDidLoad {
    [super viewDidLoad];
    testViewController *tvc = [[testViewController alloc] init];
    [self addChildViewController:tvc];
//    tvc.title = @"会话";
    UITabBarItem *tbi = [[UITabBarItem alloc] initWithTitle:@"会话" image:nil tag:1];
    tvc.tabBarItem = tbi;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
