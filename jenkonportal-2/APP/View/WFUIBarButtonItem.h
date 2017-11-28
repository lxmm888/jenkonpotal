//
//  WFUIBarButtonItem.h
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/18.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFUIBarButtonItem : UIBarButtonItem

//
@property (nonatomic, strong) UIButton *button;

//初始化包含图片的UIBarButtonItem
- (WFUIBarButtonItem *)initContainImage:(UIImage *)buttonImage imageViewFrame:(CGRect)imageFrame buttonTitle:(NSString *)buttonTitle titleColor:(UIColor*)titleColor titleFrame:(CGRect)titleFrame buttonFrame:(CGRect)buttonFrame target:(id)target action:(SEL)method;

//初始化不包含图片的UIBarButtonItem
- (WFUIBarButtonItem *)initWithbuttonTitle:(NSString *)buttonTitle titleColor:(UIColor*)titleColor buttonFrame:(CGRect)buttonFrame target:(id)target action:(SEL)method;

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick buttonColor:(UIColor *)buttonColor barButtonItem:(WFUIBarButtonItem *)barButtonItem;

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *) setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation;

@end
