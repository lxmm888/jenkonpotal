//
//  WFYHomePortalHeader.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomePortalHeader.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"

@implementation WFYHomePortalHeader
{
    UIView *_item;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
}

- (void)createUI
{
    _item = [[UIView alloc] init];
    [self addSubview:_item];
    
    UILabel *title = [[UILabel alloc] init];
    [self addSubview:title];
    _title = title;
}

- (void)bindUIValue
{
    _item.backgroundColor = RGB(0, 90, 119);
    
    _title.textColor = [UIColor grayColor];
    _title.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat itemLeftMargin = w/30;
    CGFloat itemW = itemLeftMargin/3, itemH = h*0.6, itemX = itemLeftMargin, itemY = (h-itemH)/2;
    _item.frame = CGRectMake(itemX, itemY, itemW, itemH);
    
    CGFloat titleLeftMarginToItemRight = itemW;
    CGFloat titleW = w/2, titleH = h, titleX = itemX+itemW+titleLeftMarginToItemRight, titleY = 0;
    _title.frame = CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutUI];
    [self bindUIValue2];
}

- (void)bindUIValue2
{
    _item.layer.masksToBounds = YES;
    _item.layer.cornerRadius = _item.frame.size.width/3;
}

@end
