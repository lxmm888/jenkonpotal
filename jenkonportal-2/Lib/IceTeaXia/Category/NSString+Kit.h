//
//  NSString+Kit.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/9/22.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Kit)

- (CGSize)sizeThatFit:(CGSize)fitSize withFont:(UIFont *)font;

- (NSString *)WFYURLString;

@end
