//
//  UIView+AddLongPressEvent.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/15.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "UIView+AddLongPressEvent.h"
#import <objc/message.h>

@interface  UIView ()

@property void(^longPressActon)(id);

@end

@implementation UIView (AddLongPressEvent)

- (void)setLongPressActon:(void (^)(id))longPressActon{
    objc_setAssociatedObject(self, @"AddLongPressEvent", longPressActon, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))longPressActon{
    return objc_getAssociatedObject(self, @"AddLongPressEvent");
}

- (void)addLongPressBlockWithDuration:(double)duration
                                     :(void (^)(id))longPressAction{
    self.longPressActon = longPressAction;
    //if (![self gestureRecognizers])
    {
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(longPress:)
                                                     ];
        longPressGr.minimumPressDuration = duration;
        [self addGestureRecognizer:longPressGr];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state== UIGestureRecognizerStateBegan && self.longPressActon) {
        self.longPressActon(self);
    }
}

@end
