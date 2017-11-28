//
//  WFYCollectionModel.h
//  jenkonportal
//
//  Created by 赵立 on 2017/11/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFYCollectionModel : NSObject


#define kStandardFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]]
#define kTimeLabelFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1]
#define kTitleLabelFont [UIFont boldSystemFontOfSize:[AppFontMgr standardFontSize]+2]

/** 收藏Id */
@property (nonatomic,strong) NSString *collectionId;
/** 收藏资源类型 */
@property (nonatomic,strong) NSString *collectionSourceType;
/** 收藏资源名称 */
@property (nonatomic,strong) NSString *collectionSourceName;
/** 收藏资源Id */
@property (nonatomic,strong) NSString *collectionSourceId;
/** 时间戳 */
@property (nonatomic, strong) NSString *timeStamp;
/** 配图 */
@property (nonatomic, strong) NSString *collectionPicURL;
/** 收藏内容标题 */
@property (nonatomic, strong) NSString *collectionTitle;
/** 收藏内容描述 */
@property (nonatomic, strong) NSString *collectionDesc;


@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGRect sourceLabelFrame;

@property (nonatomic, assign) CGRect timeLabelFrame;

@property (nonatomic, assign) CGRect imageViewFrame;

@property (nonatomic, assign) CGRect titleFrame;

@property (nonatomic, assign) CGRect descFrame;

@end
