//
//  NodeCell.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/8.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "XIMultiBgColorBtn.h"

@interface NodeCell : XIMultiBgColorBtn

@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitleLabel;
@property (weak, nonatomic) UIView *line;
@property (weak, nonatomic) UIImageView *rightItem;

@end
