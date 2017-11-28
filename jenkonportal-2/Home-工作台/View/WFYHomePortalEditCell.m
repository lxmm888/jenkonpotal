//
//  WFYHomePortalEditCell.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomePortalEditCell.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"
#import "WFYHomePortalItem.h"
#import "UIImageView+WebCache.h"

@interface WFYHomePortalEditCell()

@property (weak, nonatomic) UIButton *mBgButton;
@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitle;

@end

@implementation WFYHomePortalEditCell
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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *title = [[UILabel alloc] init];
    _bg = [[UIView alloc] init];
    [self.contentView addSubview:button];
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:title];
    [self.contentView insertSubview:_bg atIndex:0];
    _mBgButton = button;
    _mImageView = imageView;
    _mTitle = title;
}

- (void)bindUIValue
{
    _bg.layer.masksToBounds = YES;
    _bg.layer.cornerRadius = SCREEN_WIDTH/36;
    _bg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    [_mBgButton setImage:[UIImage imageNamed:@"portal_cell_normal"] forState:UIControlStateNormal];
    [_mBgButton setImage:[UIImage imageNamed:@"portal_cell_disabled"] forState:UIControlStateDisabled];
    [_mBgButton setImage:[UIImage imageNamed:@"portal_cell_selected"] forState:UIControlStateSelected];
    _mBgButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);//imageEdgeInsets 表示了image距离button边框的距离
    _mBgButton.userInteractionEnabled = NO;
    
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
    
    CGFloat titleW = w, titleH = h*0.2, titleX = 0, titleY = h*0.7;//h-titleH;
    _mTitle.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat imageViewW = h*0.49, imageViewH = imageViewW, imageViewX = (w-imageViewW)/2, imageViewY = (h-titleH-imageViewH)/2;//0.5
    _mImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);

    _mBgButton.frame = self.bounds;
    
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

-(void)setCellState:(CellState)cellState{
    _cellState = cellState;
    if (cellState==DeleteState) {
        self.mBgButton.selected=true;
    }else if(cellState == NormalState ){
        self.mBgButton.enabled = true;
    }else if(cellState == DisableState){
        self.mBgButton.enabled = false;
    }
    self.userInteractionEnabled = self.mBgButton.enabled;
}

@end
