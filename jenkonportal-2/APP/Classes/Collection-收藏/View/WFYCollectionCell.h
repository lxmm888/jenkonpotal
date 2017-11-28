//
//  WFYCollectionCell.h
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/11.
//  Copyright © 2016年 jetsun. All rights reserved.
//
@class WFYCollectionModel;

/**
 * source + timeStamp
 * imageView + title + desc
 */

@interface WFYCollectionCell : UITableViewCell

/** 模型*/
@property (nonatomic,strong) WFYCollectionModel *collection;

@end
