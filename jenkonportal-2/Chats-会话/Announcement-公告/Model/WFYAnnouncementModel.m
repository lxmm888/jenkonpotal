//
//  WFYAnnouncementModel.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/19.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnnouncementModel.h"
#import "AppFontMgr.h"
#import "NSString+Kit.h"
#import "WFYTimeTool.h"

@implementation WFYAnnouncementModel
#pragma mark - 其他
static NSDateFormatter *fmt_;
static NSCalendar *calendar_;

/**
 *  在第一次使用WFYAnnouncementModel类时调用1次
 */
+ (void)initialize
{
    fmt_ = [[NSDateFormatter alloc] init];
    calendar_ = [NSCalendar calendar];
}

-(NSString *)anncSendTime{
    // 获得发布日期
    fmt_.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *createdAtDate = [fmt_ dateFromString:_anncSendTime];
    
    if (createdAtDate.isThisYear) { // 今年
        if (createdAtDate.isToday) { // 今天
            // 手机当前时间
            NSDate *nowDate = [NSDate date];
            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *cmps = [calendar_ components:unit fromDate:createdAtDate toDate:nowDate options:0];
            
            if (cmps.hour >= 1) { // 时间间隔 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
            } else if (cmps.minute >= 1) { // 1小时 > 时间间隔 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 1分钟 > 分钟
                return @"刚刚";
            }
        } else if (createdAtDate.isYesterday) { // 昨天
            fmt_.dateFormat = @"昨天 HH:mm:ss";
            return [fmt_ stringFromDate:createdAtDate];
        } else { // 其他
            fmt_.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt_ stringFromDate:createdAtDate];
        }
    } else { // 非今年
        return _anncSendTime;
    }
}


-(CGFloat)cellHeight{
    if (_cellHeight==0) {
        CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
        CGFloat contentLeftMargin = (cellW - cellW * 0.9) * 0.5;
        CGFloat contentTopMargin = 0.6 * contentLeftMargin;
        //topFrame
        NSDictionary *nameAtt = @{NSFontAttributeName :kTopLabelFont};
        // 计算发布时间文字的尺寸
        CGSize anncSendTimeSize = [[WFYTimeTool timeStr:[_timeStamp longLongValue]] sizeWithAttributes:nameAtt];
        CGFloat topLabelW = anncSendTimeSize.width+contentLeftMargin;
        CGFloat topLabelH = anncSendTimeSize.height;
        CGFloat topLabelX = (cellW-topLabelW) * 0.5;
        CGFloat topLabelY = contentTopMargin;
        self.topFrame = CGRectMake(topLabelX, topLabelY, topLabelW, topLabelH);
        
        //boxFrame
        CGFloat boxViewW = cellW - 2 * contentLeftMargin;
        CGFloat boxViewX = contentLeftMargin;
        
        CGFloat boxViewY = CGRectGetMaxY(self.topFrame) + contentLeftMargin;
        
        //titleFrame
        CGFloat titleLabelX = contentLeftMargin;
        CGFloat titleLabelY = contentLeftMargin;
        CGFloat titleLabelW = boxViewW- 2 * contentLeftMargin;
        //最大宽度是titleLabelW,高度不限制
        CGFloat titleLabelH = [self.anncTopic sizeThatFit:CGSizeMake(titleLabelW, MAXFLOAT)
                                                 withFont:kTitleLabelFont].height;
        self.titleFrame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        
        //publisherFrame
        CGFloat publisherLabelX = CGRectGetMinX(self.titleFrame);
        CGFloat publisherLabelW = titleLabelW;
        CGFloat publisherLabelH = [@"" sizeThatFit:CGSizeMake(titleLabelW, MAXFLOAT)
                                          withFont:kStandardFont].height;
        CGFloat publisherLabelY = CGRectGetMaxY(self.titleFrame)+contentTopMargin;
        self.publisherFrame = CGRectMake(publisherLabelX, publisherLabelY, publisherLabelW, publisherLabelH);
        
        //imageFrame
        CGFloat descLabelY = 0;
        if ([self.anncPicURL length]>0) {//有配图
            CGFloat imageViewX = CGRectGetMinX(self.titleFrame);
            CGFloat imageViewWH = titleLabelW;
            CGFloat imageViewY = CGRectGetMaxY(self.publisherFrame)+contentTopMargin;
            self.imageFrame = CGRectMake(imageViewX, imageViewY, imageViewWH, imageViewWH);
            descLabelY = CGRectGetMaxY(self.imageFrame)+contentTopMargin;
        }
        else
        {
            self.imageFrame = CGRectZero;
            descLabelY = CGRectGetMaxY(self.publisherFrame)+contentTopMargin;
        }
        
        
        //descFrame
        CGFloat descLabelX = CGRectGetMinX(self.titleFrame);
        CGFloat descLabelW = titleLabelW;
        // 最大宽度是descLabelW,高度不限制
        CGFloat descLabelH = [self.anncSummary sizeThatFit:CGSizeMake(descLabelW, MAXFLOAT)
                                                  withFont:kStandardFont].height;
        self.descFrame = CGRectMake(descLabelX, descLabelY, descLabelW, descLabelH);
        
        //lineFrame
        CGFloat lineX = CGRectGetMinX(self.titleFrame);
        CGFloat lineH = 1;
        CGFloat lineY = CGRectGetMaxY(self.descFrame)+contentTopMargin;
        CGFloat lineW = titleLabelW;
        self.lineFrame = CGRectMake(lineX, lineY, lineW, lineH);
        
        //bottomLabelFrame
        CGFloat bottomLabelX = CGRectGetMinX(self.titleFrame);
        CGFloat bottomLabelY = CGRectGetMaxY(self.lineFrame)+contentTopMargin;
        CGSize  bottomLabelSize =[@"详情" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kBottomLabelFont];
        CGFloat bottomLabelW = bottomLabelSize.width;
        CGFloat bottomLabelH = bottomLabelSize.height;
        self.bottomLabelFrame =CGRectMake(bottomLabelX, bottomLabelY, bottomLabelW, bottomLabelH);

        //rightItemFrame
        CGFloat rightItemWH = bottomLabelH;
        CGFloat rightItemY = bottomLabelY;
        CGFloat rightItemX = boxViewW - contentLeftMargin - rightItemWH;
        self.rightItemFrame = CGRectMake(rightItemX, rightItemY, rightItemWH, rightItemWH);
        
        CGFloat boxViewH = CGRectGetMaxY(self.bottomLabelFrame)+contentLeftMargin;
        self.boxViewFrame = CGRectMake(boxViewX, boxViewY, boxViewW, boxViewH);

        _cellHeight = CGRectGetMaxY(self.boxViewFrame)+contentLeftMargin;
    }
    return _cellHeight;
}

@end
