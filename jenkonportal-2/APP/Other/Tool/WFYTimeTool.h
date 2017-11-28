//
//  WFYTimeTool.h
//  jenkonportal
//
//  Created by 赵立 on 2017/11/2.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFYTimeTool : NSObject

/**
 *  返回格式化后的时间
 *
 *  @param timestamp 时间戳
 */
+ (NSString *)timeStr:(long long)timestamp; 
@end
