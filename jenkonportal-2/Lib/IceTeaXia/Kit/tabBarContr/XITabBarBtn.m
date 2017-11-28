//
//  XITabBarBtn.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "XITabBarBtn.h"
#import "XICommonDef.h"

#define imgHRatio 0.73
#define marginImgToTopRatio 0.015

@implementation XITabBarBtn

- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    [self setTitle:_item.title forState:UIControlStateNormal];
    
    [self setImage:_item.image forState:UIControlStateNormal];
    [self setImage:_item.selectedImage forState:UIControlStateSelected];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:10];
        [self setTitleColor:RGB(136, 136, 136) forState:UIControlStateNormal];
        [self setTitleColor:RGB(0, 90, 119) forState:UIControlStateSelected];
        // self.showsTouchWhenHighlighted = YES;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

// override
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageH = contentRect.size.height * imgHRatio;
    CGFloat imageW = imageH;
    return CGRectMake(contentRect.size.width/2 - imageW/2, contentRect.size.height * marginImgToTopRatio, imageW, imageH);
}

// override
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height * (1-imgHRatio) *0.36;
    CGFloat titleY = contentRect.size.height * (imgHRatio+marginImgToTopRatio);
    return CGRectMake(0, titleY, titleW, titleH);
}

@end
