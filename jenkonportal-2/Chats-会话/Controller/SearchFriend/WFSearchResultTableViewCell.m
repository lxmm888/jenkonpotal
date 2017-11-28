//
//  WFSearchResultTableViewCell.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFSearchResultTableViewCell.h"

@implementation WFSearchResultTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _ivAva = [UIImageView new];
        _ivAva.clipsToBounds = YES;
        _ivAva.layer.cornerRadius = 5.f;
        _lblName = [UILabel new];
        
        [self addSubview:_ivAva];
        [self addSubview:_lblName];
        
        [_ivAva setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_lblName setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:[_ivAva(56)]"
          options:kNilOptions
          metrics:nil
          views:NSDictionaryOfVariableBindings(
                                               _ivAva)]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_ivAva
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1.0f
                             constant:0]];
        
        [self addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:[_lblName(20)]"
          options:kNilOptions
          metrics:nil
          views:NSDictionaryOfVariableBindings(
                                               _lblName)]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_lblName
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1.0f
                             constant:0]];
        
        [self addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:
          @"H:|-15-[_ivAva(56)]-8-[_lblName]-16-|"
          options:kNilOptions
          metrics:nil
          views:NSDictionaryOfVariableBindings(
                                               _ivAva, _lblName)]];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
