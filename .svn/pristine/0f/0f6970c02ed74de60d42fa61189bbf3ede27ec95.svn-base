//
//  XIProgressView.m
//  jenkon
//
//  Created by 冯文林  on 17/5/4.
//  Copyright © 2017年 com.huiyang. All rights reserved.
//

#import "XIProgressView.h"

@implementation XIProgressView

- (void)done
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0;
        } completion:nil];
    }];
    [self setProgress:1.0 animated:YES];
    [CATransaction commit];
}

- (void)clear
{
    self.progress = 0;
    self.alpha = 1;
}

@end
