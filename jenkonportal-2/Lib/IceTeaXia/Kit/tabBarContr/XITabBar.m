//
//  XITabBar.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "XITabBar.h"
#import "XITabBarBtn.h"

@implementation XITabBar
{
    NSMutableArray<XITabBarBtn *> *_tabs;
    // 记录当前选择的tab
    XITabBarBtn *_curTab;
}

// override
- (void)setTabItmes:(NSMutableArray<UITabBarItem *> *)tabItmes
{
    _tabItmes = tabItmes;
    
    [self initUI];
}

// override，防止系统自动add UITabBarButton
- (void)addSubview:(UIView *)view
{
    if ([view isMemberOfClass:NSClassFromString(@"UITabBarButton")]) return;
    [super addSubview:view];
}

// 点击事件
- (void)tapTab:(id)sender
{
    XITabBarBtn *tab = (XITabBarBtn *)sender;
    [self setTabHighlighted:tab];
    
    // 回调contr改变selectedIndex
    [self.mDelegate didSelectBtnTag:tab.tag];
}

- (void)setTabHighlighted:(XITabBarBtn *)tab
{
    _curTab.selected = NO;
    
    tab.selected = YES;
    _curTab = tab;
}

// 初始化成员变量
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.translucent = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        _tabItmes = [@[] mutableCopy];
        _tabs = [@[] mutableCopy];
    }
    return self;
}

// 初始化tab的UI
- (void)initUI
{
    [self createUI];
    [self bindUIValue];
}

// 创建UI
- (void)createUI
{
    for (NSInteger i=0; i<_tabItmes.count; i++) {
        XITabBarBtn *tab = [[XITabBarBtn alloc] init];
        [self addSubview:tab];
        [_tabs addObject:tab];
    }
}

// 绑定参数
- (void)bindUIValue
{
    [self setTabHighlighted:[_tabs firstObject]];
    
    [_tabs enumerateObjectsUsingBlock:^(XITabBarBtn * _Nonnull tab, NSUInteger idx, BOOL * _Nonnull stop) {
        
        tab.item = _tabItmes[idx];
        tab.tag = idx;
        [tab addTarget:self action:@selector(tapTab:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

// 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat tabCenterY = h * 0.5;
    CGFloat tabW = w/_tabItmes.count;
    CGFloat tabH = h;
    
    [_tabs enumerateObjectsUsingBlock:^(XITabBarBtn * _Nonnull tab, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat btnCenterX = tabW*0.5+tabW*idx;
        tab.bounds = CGRectMake(0, 0, tabW, tabH);
        tab.center = CGPointMake(btnCenterX, tabCenterY);
        tab.tag = idx;
    }];
}

@end
