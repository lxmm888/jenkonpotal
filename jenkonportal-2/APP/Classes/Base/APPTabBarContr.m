//
//  HelloContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "APPTabBarContr.h"
#import "WFYHomeContr.h"
#import "MeContr.h"
#import "ChatsContr.h"
#import "BaseNaviContr.h"
#import "ContactsContr.h"

@implementation APPTabBarContr
{
    NSMutableDictionary *_redPoints;// 小红点
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initIvar];
    }
    return self;
}

- (void)initIvar
{
    // tabBarItems
    NSMutableArray<UITabBarItem *> *items = [@[] mutableCopy];
    NSArray *title = @[
                       @"消息",
                       @"通讯录",
                       @"工作台",
                       @"我的"
                       ];
    NSArray *imgs = @[
                      @"tabBar_msg",
                      @"tabBar_contacts",
                      @"tabBar_workbench",
                      @"tabBar_me"
                      ];
    for (NSInteger i = 0; i<4; i++) {
        
        UITabBarItem *item = [[UITabBarItem alloc] init];
        item.title = title[i];
        item.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", imgs[i]]];
        item.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", imgs[i]]];
        [items addObject:item];
        
    }
    self.tabBarItems = items;
    
    // child contrs
    BaseNaviContr *chats = [[BaseNaviContr alloc] initWithRootViewController:[[ChatsContr alloc] init]];
    [self addChildViewController:chats];
    
    BaseNaviContr *contacts = [[BaseNaviContr alloc] initWithRootViewController:[[ContactsContr alloc] init]];
    [self addChildViewController:contacts];
    
    BaseNaviContr *home = [[BaseNaviContr alloc] initWithRootViewController:[[WFYHomeContr alloc] init]];
    [self addChildViewController:home];
    
    BaseNaviContr *me = [[BaseNaviContr alloc] initWithRootViewController:[[MeContr alloc] init]];
    [self addChildViewController:me];
    
    _redPoints = [@{} mutableCopy];
}

- (void)hideRedPoint:(BOOL)hidden :(NSInteger)idx
{
    UIView *redPoint = _redPoints[@(idx)];
    
    if (!hidden&&!redPoint) {
        redPoint = [[UIView alloc] init];
        _redPoints[@(idx)] = redPoint;
        
        redPoint.backgroundColor = [UIColor redColor];
        
        CGFloat tabBarW = self.tabBar.bounds.size.width, tabBarH = kTabBarH, tabW = tabBarW/4;
        CGFloat centerX = tabW*idx+0.7*tabW, centerY = tabBarH*0.25, w = tabW/9, h = w;
        CGRect bounds = CGRectMake(0, 0, w, h);
        CGPoint center = CGPointMake(centerX, centerY);
        redPoint.bounds = bounds;
        redPoint.center = center;
        
        redPoint.layer.masksToBounds = YES;
        redPoint.layer.cornerRadius = h/2;
        
        [self.tabBar addSubview:redPoint];
    }
    
    redPoint.hidden = hidden;
}

@end
