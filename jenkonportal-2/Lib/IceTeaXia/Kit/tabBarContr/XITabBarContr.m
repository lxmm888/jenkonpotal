//
//  XITabBarContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "XITabBarContr.h"
#import "XITabBar.h"

@interface XITabBarContr ()<XITabBarDelegate>

@end

@implementation XITabBarContr

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI
{
    XITabBar *tabBar = [[XITabBar alloc] initWithFrame:self.tabBar.bounds];
    tabBar.mDelegate = self;
    [self setValue:tabBar forKey:@"tabBar"];
}

// override
- (void)setTabBarItems:(NSMutableArray<UITabBarItem *> *)tabBarItems
{
    _tabBarItems = tabBarItems;
    ((XITabBar *)self.tabBar).tabItmes = tabBarItems;
}

#pragma mark - XITabBarDelegate
- (void)didSelectBtnTag:(NSInteger)tag
{
    self.selectedIndex = tag;
}

@end
