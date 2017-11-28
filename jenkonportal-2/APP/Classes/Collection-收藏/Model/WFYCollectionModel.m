//
//  WFYCollectionModel.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYCollectionModel.h"
#import "NSString+Kit.h"

@implementation WFYCollectionModel

- (CGFloat)cellHeight{
    if (_cellHeight) return _cellHeight;
    
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    CGFloat leftMargin = cellW/36,space = leftMargin * 0.5;
    
    //sourceLabelFrame
    CGFloat sourceLabelX = leftMargin;
    CGFloat sourceLabelY = leftMargin;
    CGSize  sourceLabelSize =[self.collectionSourceName sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kStandardFont];
    CGFloat sourceLabelW = sourceLabelSize.width;
    CGFloat sourceLabelH = sourceLabelSize.height;
    _sourceLabelFrame = CGRectMake(sourceLabelX, sourceLabelY, sourceLabelW, sourceLabelH);
    
    //timeLabelFrame
    CGSize timeLabelSize = [[WFYTimeTool timeStr:[_timeStamp longLongValue]] sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kTimeLabelFont];
    CGFloat timeLabelW = timeLabelSize.width;
    CGFloat timeLabelH = timeLabelSize.height;
    CGFloat timeLabelX = cellW-leftMargin-timeLabelW;
    CGFloat timeLabelY = CGRectGetMaxY(_sourceLabelFrame)-timeLabelH;
    _timeLabelFrame=  CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH);
    
    
    if (_collectionPicURL && _collectionPicURL.length>0){
        //imageViewFrame
        CGFloat imageViewH = cellW*0.2;
        CGFloat imageViewW = imageViewH;
        CGFloat imageViewX = leftMargin;
        CGFloat imageViewY = CGRectGetMaxY(_sourceLabelFrame) + space;
        _imageViewFrame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
        
        //titleFrame
        CGFloat titleLabelX = CGRectGetMaxX(_imageViewFrame) + space;
        CGFloat titleLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kTitleLabelFont].height;
        CGFloat titleLabelW = cellW-2*leftMargin - imageViewW -space;
        
        //descFrame
        CGFloat descLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kStandardFont].height;
        CGFloat descLabelW = titleLabelW;
        CGFloat descTopMarginToTitleBotm = imageViewH*0.1;
        CGFloat marginTitleLabelToImageViewTop = (imageViewH-titleLabelH-descTopMarginToTitleBotm-descLabelH)/2;
        
        _titleFrame = CGRectMake(titleLabelX, CGRectGetMinY(_imageViewFrame)+marginTitleLabelToImageViewTop, titleLabelW, titleLabelH);
        _descFrame  = CGRectMake(CGRectGetMinX(_titleFrame), CGRectGetMaxY(_titleFrame)+descTopMarginToTitleBotm, descLabelW, descLabelH);
        
        _cellHeight =  CGRectGetMaxY(_imageViewFrame)+leftMargin ;
    }
    else{
        _imageViewFrame = CGRectZero;
        _descFrame = CGRectZero;
        //titleFrame
        CGFloat titleLabelX = leftMargin;
        CGFloat titleLabelY = CGRectGetMaxY(_sourceLabelFrame) + space;
        CGFloat titleLabelW = cellW-2*leftMargin;
        CGFloat titleLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kTitleLabelFont].height;
        _titleFrame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        _cellHeight =  CGRectGetMaxY(_titleFrame)+leftMargin ;
    }

    return _cellHeight;
}

@end
