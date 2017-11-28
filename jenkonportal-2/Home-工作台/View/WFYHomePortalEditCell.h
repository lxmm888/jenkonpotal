//
//  WFYHomePortalEditCell.h
//  jenkonportal
//
//  Created by 赵立 on 2017/10/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WFYHomePortalItem;

typedef NS_ENUM(NSInteger,CellState){
    //右上角编辑按钮的三种状态：
    //可以添加时候的状态
    NormalState,
    //可以删除时候的状态
    DeleteState,
    //无法点击时候的状态
    DisableState
};

@interface WFYHomePortalEditCell : UICollectionViewCell

/** 模型*/
@property (nonatomic,strong) WFYHomePortalItem *portal;
@property(nonatomic,assign) CellState cellState;

@end
