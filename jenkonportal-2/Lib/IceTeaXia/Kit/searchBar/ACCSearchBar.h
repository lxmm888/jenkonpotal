//
//  ACCSearchBar.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/24.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ACCSearchBarLeftItemStyleSearchWhite,
    ACCSearchBarLeftItemStyleSearchGray,
} ACCSearchBarLeftItemStyle;

@interface ACCSearchBar : UIView

@property (weak, nonatomic) UIImageView *leftItem;
@property (weak, nonatomic) UIButton *clearBtn;
@property (weak, nonatomic) UITextField *textField;
@property (assign, nonatomic) ACCSearchBarLeftItemStyle leftItemStyle;
- (void)layoutUI;
- (void)setPlaceholderTextColor:(UIColor *)color;

@end
