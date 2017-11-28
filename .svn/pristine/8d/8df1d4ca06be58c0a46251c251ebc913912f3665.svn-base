//
//  NodeCell.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/8.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "NodeCell.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"

@implementation NodeCell

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
    UIImageView *imgV = [[UIImageView alloc] init];
    [self addSubview:imgV];
    _mImageView = imgV;
    
    UIImageView *rightItem = [[UIImageView alloc] init];
    [self addSubview:rightItem];
    _rightItem = rightItem;
    
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    _mTitleLabel = label;
    
    UIView *line = [[UIView alloc] init];
    [self addSubview:line];
    _line = line;
}

- (void)bindUIValue
{
    _mImageView.contentMode = UIViewContentModeScaleToFill;
    
    _rightItem.image = [UIImage imageNamed:@"common_rightItem"];
    
    _mTitleLabel.textColor = RGB(67, 66, 64);
    _mTitleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+1];
    _mTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    _line.backgroundColor = RGB(226, 226, 226);
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
    
    CGFloat marginImgVToLeft = w/36;
    CGFloat marginImgVToTop = marginImgVToLeft*0.9;
    CGFloat imgVH = h-2*marginImgVToTop;
    _mImageView.frame = CGRectMake(marginImgVToLeft, marginImgVToTop, imgVH, imgVH);
    
    CGFloat rightItemH = h*0.2;
    CGFloat marginRightItemToRight = marginImgVToLeft;
    _rightItem.frame = CGRectMake(w-marginRightItemToRight-rightItemH, h/2 - rightItemH/2, rightItemH, rightItemH);
    
    CGFloat labelW = w-imgVH-2*marginImgVToLeft-marginImgVToLeft-rightItemH-marginRightItemToRight;
    _mTitleLabel.frame = CGRectMake(CGRectGetMaxX(_mImageView.frame)+marginImgVToLeft, h/2-imgVH/2, labelW, imgVH);
    
    CGFloat lineH = 1;
    _line.frame = CGRectMake(marginImgVToLeft, h-lineH, w-2*marginImgVToLeft, lineH);
}

@end
