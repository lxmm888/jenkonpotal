//
//  WFYTimeTool.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/2.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYTimeTool.h"
#import <UIKit/UIKit.h>
#import "NSDate+DateTools.h"

@implementation WFYTimeTool

+ (NSString *)timeStr:(long long)timestamp
{
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    // 判断
    if ([msgDate isThisYear]) {//今年
        if ([msgDate isToday]){//今天
            if ([msgDate hoursAgo]<1) {//1小时之内
                if ([msgDate minutesAgo]<1) {//1分钟内
                    return @"刚刚";
                }
                return [NSString stringWithFormat:@"%d分钟前",(int)[msgDate minutesAgo]];
            }
            return [msgDate formattedDateWithFormat:@"H:mm"];
        }
        else{
            if ([msgDate isYesterday]){//昨天
                return [msgDate formattedDateWithFormat:@"昨天 HH:mm"];
            }else if([msgDate weeksAgo]==0){//本周
                return [msgDate formattedDateWithFormat:@"EEE HH:mm"];
            }
            else{
                return [msgDate formattedDateWithFormat:@"MM月dd日 HH:mm"];
            }
        }
    }else{
        return [msgDate formattedDateWithFormat:@"yyyy年MM月dd日 HH:mm"];
    }
    
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    // 获取当前时间的年、月、日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    // 获取消息发送时间的年、月、日
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    CGFloat msgYear = msgDate.year;
    CGFloat msgMonth = msgDate.month;
    CGFloat msgDay = msgDate.day;
    
    // 判断
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    if (currentYear == msgYear && currentMonth == msgMonth && currentDay == msgDay) {
        //今天
        dateFmt.dateFormat = @"HH:mm";
    }else if (currentYear == msgYear && currentMonth == msgMonth && currentDay-1 == msgDay ){
        //昨天
        dateFmt.dateFormat = @"昨天 HH:mm";
    }else{
        //昨天以前
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    return [dateFmt stringFromDate:msgDate];
    */
}

@end
