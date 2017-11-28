//
//  NodeWithImgDescCell.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/11.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "XIMultiBgColorBtn.h"

/**
 * imageView + title + desc + rightItem
 */

@interface ITDRCell : XIMultiBgColorBtn

@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitleLabel;
@property (weak, nonatomic) UILabel *descLabel;
@property (weak, nonatomic) UIImageView *rightItem;
@property (weak, nonatomic) UIView *line;
- (void)layoutUI;

@end
