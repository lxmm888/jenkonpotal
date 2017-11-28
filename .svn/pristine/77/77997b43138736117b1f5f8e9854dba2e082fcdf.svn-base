//
//  BlockButton.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/8.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "BlockButton.h"

@interface BlockButton ()

@property (strong, nonatomic) HandleTapBlock tapHandler;

@end

@implementation BlockButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initGesture];
    }
    return self ;
}

- (void)handleTapWithBlock:(HandleTapBlock)handler
{
    _tapHandler = handler;
}

- (void)handleTap
{
    if (_tapHandler != NULL) {
        __weak __typeof(self)weakSelf = self;
        _tapHandler(weakSelf);
    }
}

- (void)initGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

@end
