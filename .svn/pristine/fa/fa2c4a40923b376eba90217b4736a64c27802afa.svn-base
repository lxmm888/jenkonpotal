//
//  UnreadBadge.m
//  Test
//
//  Created by 冯文林  on 16/7/2.
//  Copyright © 2016年 crow. All rights reserved.
//

#import "UnreadBadge.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"

#define marginWidth SCREEN_WIDTH/36
#define marginHeight marginWidth*0.8

@implementation UnreadBadge


- (instancetype)init
{
    if (self = [super init]) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = RGB(235, 79, 56);
        self.font  = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setUnreadCount:(NSInteger)unreadCount
{
    _unreadCount = unreadCount;
    
    if (unreadCount <= 0) {
        self.bounds = CGRectZero;
        return;
    }
    
    CGPoint center = self.center;
    NSString *text = nil;
    if (unreadCount > 99) {
        text = @"99+";
    }else {
        text = [NSString stringWithFormat:@"%ld", unreadCount];
    }
    self.text = text;
    [self sizeToFit];
    CGFloat marginW = marginWidth;
    CGFloat marginH = marginHeight;
    CGFloat fixLabelH = self.bounds.size.height + marginH;
    CGFloat fixW = self.bounds.size.width + marginW;
    CGFloat fixLabelW = fixW<fixLabelH ? fixLabelH : fixW;
    CGSize size = (CGSize){fixLabelW, fixLabelH};
    self.bounds = (CGRect){CGPointZero, size};
    self.layer.cornerRadius = fixLabelH/2;
    self.center = center;
}

- (CGSize)getMaxSize
{
    CGSize textSize = [@"99+" boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    return (CGSize){(NSInteger)(textSize.width+marginWidth+0.5), (NSInteger)(textSize.height+marginHeight+0.5)};
}

@end
