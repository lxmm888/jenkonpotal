//
//  NodeWithImgDescCell.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/11.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "ITDRCell.h"
#import "NSString+Kit.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"

@implementation ITDRCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
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
    UIImageView *rightItem = [[UIImageView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    UILabel *descLabel = [[UILabel alloc] init];
    UIView *line = [[UIView alloc] init];
    
    [self addSubview:imageView];
    [self addSubview:rightItem];
    [self addSubview:titleLabel];
    [self addSubview:descLabel];
    [self addSubview:line];
 
    _mImageView = imageView;
    _rightItem = rightItem;
    _mTitleLabel = titleLabel;
    _descLabel = descLabel;
    _line = line;
}

- (void)bindUIValue
{
    _rightItem.image = [UIImage imageNamed:@"common_rightItem"];
    
    _mTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mTitleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+2];
    _mTitleLabel.textColor = RGB(54, 54, 54);
    
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]];
    _descLabel.textColor = RGB(146, 144, 144);
    
    _line.backgroundColor = RGB(228, 235, 235);
}

- (void)layoutUI
{
    CGFloat cellW = self.bounds.size.width;
    CGFloat cellH = self.bounds.size.height;
    
    CGFloat imageViewH = cellH*0.75;
    CGFloat imageViewW = imageViewH;
    CGFloat marginImageViewToTop = (cellH-imageViewH)/2;
    _mImageView.frame = CGRectMake(marginImageViewToTop, marginImageViewToTop, imageViewW, imageViewH);
    
    CGFloat rightItemH = cellH*0.15;
    CGFloat marginRightItemToRight = marginImageViewToTop;
    _rightItem.frame = CGRectMake(cellW-marginRightItemToRight-rightItemH, cellH/2-rightItemH/2, rightItemH, rightItemH);
    
    CGFloat titleLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_mTitleLabel.font].height;
    CGFloat marginTitleLabelToLeft = marginImageViewToTop;
    CGFloat titleLabelW = cellW-marginImageViewToTop-imageViewW-marginTitleLabelToLeft-rightItemH-2*marginRightItemToRight;
    
    CGFloat descLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_descLabel.font].height;
    CGFloat descLabelW = titleLabelW;
    CGFloat descTopMarginToTitleBotm = imageViewH*0.1;
    CGFloat marginTitleLabelToImageViewTop = (imageViewH-titleLabelH-descTopMarginToTitleBotm-descLabelH)/2;
    
    _mTitleLabel.frame = CGRectMake(CGRectGetMaxX(_mImageView.frame)+marginImageViewToTop, CGRectGetMinY(_mImageView.frame)+marginTitleLabelToImageViewTop, titleLabelW, titleLabelH);
    
    _descLabel.frame = CGRectMake(CGRectGetMinX(_mTitleLabel.frame), CGRectGetMaxY(_mTitleLabel.frame)+descTopMarginToTitleBotm, descLabelW, descLabelH);
    
    CGFloat lineH = 1;
    _line.frame = CGRectMake(0, cellH-lineH, cellW, lineH);
}

@end
