//
//  ACCMutiBgColorBtn.m
//  ACCSupport
//
//  Created by 冯文林 on 16/8/15.
//  Copyright © 2016年 ACCWilliam. All rights reserved.
//

#import "XIMultiBgColorBtn.h"

@interface XIMultiBgColorBtn ()

@property (strong, nonatomic) UIColor *norColor;
@property (strong, nonatomic) UIColor *hltColor;
@property (strong, nonatomic) UIColor *disColor;

@end

@implementation XIMultiBgColorBtn

- (void)setBackgroundColorForStateNormal:(UIColor *)norColor hightlighted:(UIColor *)hltColor;
{
    _norColor = norColor;
    _hltColor = hltColor;
    self.backgroundColor = norColor;
}

- (void)setBackgroundColorForStateNormal:(UIColor *)norColor hightlighted:(UIColor *)hltColor disable:(UIColor *)disColor
{
    _norColor = norColor;
    _hltColor = hltColor;
    _disColor = disColor;
    self.backgroundColor = norColor;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.backgroundColor = self.hltColor;
    }else {
        self.backgroundColor = self.norColor;
    }
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.backgroundColor = self.hltColor;
    }else {
        if (!self.selected) {
            self.backgroundColor = self.norColor;
        } 
    }
    [super setHighlighted:highlighted];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    if (userInteractionEnabled) {
        self.backgroundColor = self.norColor;
    }else {
        self.backgroundColor = self.disColor;
    }
    [super setUserInteractionEnabled:userInteractionEnabled];
}

- (UIColor *)norColor
{
    if (!_norColor) {
        _norColor = self.backgroundColor;
    }
    return _norColor;
}

- (UIColor *)hltColor
{
    if (!_hltColor) {
        _hltColor = self.backgroundColor;
    }
    return _hltColor;
}

- (UIColor *)disColor
{
    if (!_disColor) {
        _disColor = self.backgroundColor;
    }
    return _disColor;
}

@end
