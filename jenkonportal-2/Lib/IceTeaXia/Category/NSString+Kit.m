//
//  NSString+Kit.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/9/22.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "NSString+Kit.h"


@implementation NSString (Kit)

- (CGSize)sizeThatFit:(CGSize)fitSize withFont:(UIFont *)font
{
    CGSize textSize = [self boundingRectWithSize:fitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return textSize;
}

- (NSString *)WFYURLString{    
    //转换编码
    NSString *urlString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //去除空格
    urlString =[urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return urlString;
}

@end
