//
//  WFYHomePortalItem.h
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFYHomePortalItem : NSObject

/** 名字 */
@property (nonatomic, copy) NSString *Name;
/** 图标 */
@property (nonatomic, copy) NSString *Icon;
/** 路径 */
@property (nonatomic, copy) NSString *URL;
/** 分类 */
@property (nonatomic, copy) NSString *Type;
/** 默认项标记*/
@property (nonatomic, copy) NSString *DefaultFlag;

@end
