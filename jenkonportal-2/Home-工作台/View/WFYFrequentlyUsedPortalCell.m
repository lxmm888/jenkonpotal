//
//  WFYFrequentlyUsedPortalCell.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYFrequentlyUsedPortalCell.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"
#import "WFYHomePortalItem.h"
#import "UIImageView+WebCache.h"

@interface WFYFrequentlyUsedPortalCell()
@property (weak, nonatomic) UIImageView *mImageView;
@end

@implementation WFYFrequentlyUsedPortalCell
{
    UIView *_bg;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
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
    UIImageView *imageView = [[UIImageView alloc] init];
    _bg = [[UIView alloc] init];
    [self.contentView addSubview:imageView];
    [self.contentView insertSubview:_bg atIndex:0];
    
    _mImageView = imageView;
}

- (void)bindUIValue
{
    _bg.layer.masksToBounds = YES;
    _bg.layer.cornerRadius = SCREEN_WIDTH/36;
    _bg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat imageViewW = h*0.8, imageViewH = imageViewW, imageViewX = (w-imageViewW)/2, imageViewY = (h-imageViewH)/2;
    _mImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    
    _bg.frame = self.bounds;
}

-(void)setPortal:(WFYHomePortalItem *)portal{
    _portal = portal;
    if ([portal.Icon hasPrefix:@"http"]) {
        [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[portal.Icon WFYURLString]]
                           placeholderImage:[UIImage imageNamed:@"home_cell_more"]];
    }
    else{
        self.mImageView.image = [UIImage imageNamed:portal.Icon];
    }
}

@end
