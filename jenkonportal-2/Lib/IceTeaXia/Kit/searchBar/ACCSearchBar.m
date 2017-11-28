//
//  ACCSearchBar.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/24.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "ACCSearchBar.h"
#import "UIImage+Size.h"
#import "AppFontMgr.h"

@interface ACCSearchBar ()<UITextFieldDelegate>

@end

@implementation ACCSearchBar

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
    UIImageView *leftItem = [[UIImageView alloc] init];
    UIButton *clearBtn = [[UIButton alloc] init];
    UITextField *textField = [[UITextField alloc] init];
    
    [self addSubview:leftItem];
    [self addSubview:clearBtn];
    [self addSubview:textField];
    textField.delegate = self;
    _leftItem = leftItem;
    _clearBtn = clearBtn;
    _textField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField.inputView resignFirstResponder];
    [_textField resignFirstResponder];
//    [self endEditing:YES];
    return YES;
}



- (void)bindUIValue
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarBeginEditing)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
    
    _clearBtn.hidden = YES;
    [_clearBtn addTarget:self action:@selector(clearTextFieldText) forControlEvents:UIControlEventTouchUpInside];
    
    _textField.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+1];
    [_textField addTarget:self action:@selector(handleTextFieldTextDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)layoutUI
{
    [self _layoutUI];
    [self bindUIValue2];
}

- (void)_layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;

    CGFloat leftItemH = h*0.6;
    CGFloat marginLeftItemToTop = (h-leftItemH)/2;
    CGFloat marginLeftItemToLeft = marginLeftItemToTop/2;
    _leftItem.frame = CGRectMake(marginLeftItemToTop, marginLeftItemToTop, leftItemH, leftItemH);
    
    CGFloat marginClearBtnToRight = 0;
    CGFloat clearBtnH = h;
    _clearBtn.frame = CGRectMake(w-marginClearBtnToRight-clearBtnH, 0, clearBtnH, clearBtnH);
    
    CGFloat marginTextFieldToLeft = marginLeftItemToTop;
    CGFloat marginTextFieldToRight = 2*marginTextFieldToLeft;
    CGFloat textFieldW = w-marginLeftItemToLeft-leftItemH-marginLeftItemToLeft-marginTextFieldToRight-clearBtnH-marginClearBtnToRight;
    CGFloat textFieldH = h;
    _textField.frame = CGRectMake(CGRectGetMaxX(_leftItem.frame)+marginTextFieldToLeft, 0, textFieldW, textFieldH);}

- (void)bindUIValue2
{
    self.layer.cornerRadius = self.bounds.size.height*0.3;
    
    CGFloat clearBtnH = _clearBtn.bounds.size.height;
    CGFloat insetTop = clearBtnH*0.15;
    _clearBtn.contentEdgeInsets = UIEdgeInsetsMake(insetTop, insetTop, insetTop, insetTop);
    [_clearBtn setImage:[UIImage image:[UIImage imageNamed:@"ACCSearchBar_clear"] aspectThatFill:_clearBtn.bounds.size] forState:UIControlStateNormal];
}

- (void)setPlaceholderTextColor:(UIColor *)color
{
    [_textField setValue:color forKeyPath:@"placeholderLabel.textColor"];
}

- (void)setLeftItemStyle:(ACCSearchBarLeftItemStyle)leftItemStyle
{
    _leftItemStyle = leftItemStyle;
    
    UIImage *leftItemImg = nil;
    if (leftItemStyle==ACCSearchBarLeftItemStyleSearchWhite) {
        leftItemImg = [UIImage image:[UIImage imageNamed:@"ACCSearchBar_leftItem_white"] aspectThatFill:_leftItem.bounds.size];
    }else if (leftItemStyle==ACCSearchBarLeftItemStyleSearchGray) {
        leftItemImg = [UIImage image:[UIImage imageNamed:@"ACCSearchBar_leftItem_gray"] aspectThatFill:_leftItem.bounds.size];
    }
    _leftItem.image = leftItemImg;
}

- (void)searchBarBeginEditing
{
    [_textField becomeFirstResponder];
}

- (void)handleTextFieldTextDidChange
{
    if (!_textField.text.length) {
        _clearBtn.hidden = YES;
    }else {
        _clearBtn.hidden = NO;
    }
}

- (void)clearTextFieldText
{
    _textField.text = nil;
    _clearBtn.hidden = YES;
}

@end
