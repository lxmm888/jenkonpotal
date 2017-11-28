//
//  BlockButton.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/8.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlockButton;
typedef void(^HandleTapBlock)(BlockButton *__weak weakSelf);

@interface BlockButton : UIView

- (void)handleTapWithBlock:(HandleTapBlock)handler;

@end
