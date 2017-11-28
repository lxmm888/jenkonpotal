//
//  UIView+AddLongPressEvent.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/15.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AddLongPressEvent)

- (void)addLongPressBlockWithDuration:(double )duration :(void(^)(id obj))longPressAction;

@end