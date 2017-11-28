//
//  XITagView.h
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XITagModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) id content;

@end

@interface XITagView : UIView

@property (strong, nonatomic) NSMutableArray<XITagModel *> *tagItems;
- (void)reloadData;

@end
