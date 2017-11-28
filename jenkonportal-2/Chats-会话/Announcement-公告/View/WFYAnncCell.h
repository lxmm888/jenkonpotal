//
//  WFYAnncCell.h
//  jenkonportal
//
//  Created by 赵立 on 2017/9/14.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "XIMultiBgColorBtn.h"
@class WFYAnnouncementModel;
/**
 * title + publisher +imageView +  desc + line + Bottom(Label + rightItem)
 */
@interface WFYAnncCell : UITableViewCell


@property (nonatomic,strong) UIView *boxView;
/** 模型*/
@property (nonatomic,strong) WFYAnnouncementModel *announcement;

//- (void)layoutUI;

@end
