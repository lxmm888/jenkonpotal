//
//  WFGroupSettingsContrHeaderItem.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/31.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFGroupSettingsContrHeaderItem.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "UIColor+WFColor.h"
#import "AppSession.h"

@implementation WFGroupSettingsContrHeaderItem

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
}

- (void)createUI{
    _ivAva = [[UIImageView alloc] init];
    _titleLabel = [[UILabel alloc] init];
    _btnImg = [[UIButton alloc] init];
    
    [self.contentView addSubview:_ivAva];
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_btnImg];
}

- (void)bindUIValue{
    _ivAva.frame = CGRectZero;
    _ivAva.clipsToBounds =YES;
    _ivAva.layer.cornerRadius = 5.f;
    [_ivAva setBackgroundColor:[UIColor clearColor]];
    
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"0x999999" alpha:1.0]];
    [_titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_btnImg setHidden:YES];
//    [_btnImg setImage:[AppSession imageNamed:@"delete_member_tip" ofBundle:@""] forState:UIControlStateNormal];
    [_btnImg addTarget:self
                action:@selector(deleteItem:)
      forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI{
    [_ivAva setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_btnImg setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_ivAva]"
                                                                options:kNilOptions
                                                            metrics:nil
                                                              views:NSDictionaryOfVariableBindings(_ivAva)]];
    [self.contentView
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]"
                                                            options:kNilOptions
                                                            metrics:nil
                                                              views:NSDictionaryOfVariableBindings(_titleLabel)]];
    
    [self.contentView
     addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:
      @"V:|[_ivAva(55)]-9-[_titleLabel(==15)]"
      options:kNilOptions
      metrics:nil
      views:NSDictionaryOfVariableBindings(
                                           _titleLabel, _ivAva)]];
    
    [self.contentView
     addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[_btnImg(25)]"
      options:kNilOptions
      metrics:nil
      views:NSDictionaryOfVariableBindings(
                                           _btnImg)]];
    [self.contentView
     addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|[_btnImg(25)]"
      options:kNilOptions
      metrics:nil
      views:NSDictionaryOfVariableBindings(
                                           _btnImg)]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_ivAva
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0
                                     ]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

- (void) deleteItem:(id)sender{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(deleteTipButtonClicked:)]) {
        [self.delegate deleteTipButtonClicked:self];
    }
}

- (void)setUserModel:(RCUserInfo *)userModel{
    self.ivAva.image= nil;
    self.userId =userModel.userId;
    //self.titleLabel.text = userModel.name;
    //名字过长使用...省略号
    if ([userModel.name length] > 3) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@...",[userModel.name substringToIndex:3]];
    }
    else{
        self.titleLabel.text = userModel.name;
    }
    
    if ([userModel.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:userModel.userId Nickname:userModel.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.ivAva.image = portrait;
    } else {
        [self.ivAva sd_setImageWithURL:[NSURL URLWithString:[userModel.portraitUri WFYURLString]]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}



@end
