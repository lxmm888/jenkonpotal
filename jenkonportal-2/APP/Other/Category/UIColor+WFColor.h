//
//  UIColor+RCColor.h
//  RCloudMessage
//
//  Created by Liv on 15/4/3.
//

#import <UIKit/UIKit.h>

@interface UIColor (WFColor)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// UIColor 转UIImage
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
