//
//  WFYHomePortalCell.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomePortalCell.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"
#import "UIImageView+WebCache.h"
#import "WFYHomePortalItem.h"

@interface WFYHomePortalCell()

@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitle;

@end

@implementation WFYHomePortalCell
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
    UILabel *title = [[UILabel alloc] init];
    _bg = [[UIView alloc] init];
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:title];
    [self.contentView insertSubview:_bg atIndex:0];
    
    _mImageView = imageView;
    _mTitle = title;
}

- (void)bindUIValue
{
    _bg.layer.masksToBounds = YES;
    _bg.layer.cornerRadius = SCREEN_WIDTH/36;
    _bg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    _mTitle.textAlignment = NSTextAlignmentCenter;
    _mTitle.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-4];//3
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
    
    CGFloat titleW = w, titleH = h*0.2, titleX = 0, titleY = h*0.7; //h-titleH;
    _mTitle.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat imageViewW = h*0.49, imageViewH = imageViewW, imageViewX = (w-imageViewW)/2, imageViewY = (h-titleH-imageViewH)/2;//0.5
    _mImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    
    _bg.frame = self.bounds;
}

-(void)setPortal:(WFYHomePortalItem *)portal{
    _portal = portal;
    self.mTitle.text = portal.Name;
    if ([portal.Icon hasPrefix:@"http"]) {
        [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[portal.Icon WFYURLString]]
                           placeholderImage:[UIImage imageNamed:@"home_cell_more"]];
    }
    else{
        self.mImageView.image = [UIImage imageNamed:portal.Icon];
    }
}

@end
