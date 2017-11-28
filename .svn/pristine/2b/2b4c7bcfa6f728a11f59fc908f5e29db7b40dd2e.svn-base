//
//  XITabBar.h
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XITabBarDelegate <NSObject>

- (void)didSelectBtnTag:(NSInteger)tag;

@end

@interface XITabBar : UITabBar

@property(weak, nonatomic) id<XITabBarDelegate> mDelegate;
@property(strong, nonatomic) NSMutableArray<UITabBarItem *> *tabItmes;

@end
