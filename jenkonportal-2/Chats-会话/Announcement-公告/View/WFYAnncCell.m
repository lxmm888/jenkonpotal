//
//  WFYAnncCell.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/14.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnncCell.h"
#import "NSString+Kit.h"
#import "XICommonDef.h"
#import "WFYTimeTool.h"
#import "UIView+AddClickedEvent.h"
#import "WFYAnnouncementModel.h"
#import "UIImageView+WebCache.h"

@interface WFYAnncCell()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) UILabel *topLabel;
@property (weak, nonatomic) UILabel *mTitleLabel;
@property (weak, nonatomic) UILabel *publisherLabel;
@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *descLabel;
@property (weak, nonatomic) UIImageView *rightItem;
@property (weak, nonatomic) UIView *line;
@property (weak, nonatomic) UILabel *bottomLabel;

@end

@implementation WFYAnncCell

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        [self initUI];
//    }
//    return self;
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
}

- (void)createUI
{
    UILabel *topLable = [[UILabel alloc]init];
    UIView *boxView = [[UIView alloc]init];
    UILabel *titleLabel = [[UILabel alloc] init];
    UILabel *publisherLabel = [[UILabel alloc] init];
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *descLabel = [[UILabel alloc] init];
    UIView *line = [[UIView alloc] init];
    UILabel *bottomLabel = [[UILabel alloc]init];
    UIImageView *rightItem = [[UIImageView alloc] init];
    
    [boxView addSubview:titleLabel];
    [boxView addSubview:publisherLabel];
    [boxView addSubview:imageView];
    [boxView addSubview:descLabel];
    [boxView addSubview:line];
    [boxView addSubview:bottomLabel];
    [boxView addSubview:rightItem];
    [self.contentView addSubview:topLable];
    [self.contentView addSubview:boxView];
    
    _topLabel= topLable;
    _boxView = boxView;
    _mTitleLabel = titleLabel;
    _publisherLabel =publisherLabel;
    _mImageView = imageView;
    _descLabel = descLabel;
    _line = line;
    _bottomLabel = bottomLabel;
    _rightItem = rightItem;
}

- (void)bindUIValue
{
    self.backgroundColor = RGB(235, 235, 235);
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    _topLabel.backgroundColor = RGB(212, 212, 212);
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.textColor = RGB(239, 239, 239);
    _topLabel.font = kTopLabelFont;//[UIFont systemFontOfSize:[AppFontMgr standardFontSize]-2];
    
    _boxView.backgroundColor =RGB(255, 255, 255);
    _boxView.userInteractionEnabled = YES;
//    [_boxView addClickedBlock:^(id obj) {
//        NSLog(@"我被点击了~");
//    }];
    

    _mTitleLabel.textAlignment = NSTextAlignmentLeft;
    //_mTitleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+2];
    _mTitleLabel.font = kTitleLabelFont;// 字体加粗
    _mTitleLabel.textColor = RGB(54, 54, 54);
    _mTitleLabel.numberOfLines = 0;
    
    _publisherLabel.textAlignment = NSTextAlignmentLeft;
    _publisherLabel.font = kStandardFont;
    _publisherLabel.textColor = RGB(146, 146, 146);
    
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.font = kStandardFont;
    _descLabel.textColor = RGB(54, 54, 54);//RGB(146, 146, 146);
    _descLabel.numberOfLines = 0;
    
    _line.backgroundColor =  RGB(235, 235, 235);
    
    _bottomLabel.textAlignment = NSTextAlignmentLeft;
    _bottomLabel.font =kBottomLabelFont;
    _bottomLabel.textColor = RGB(54, 54, 54);
    _bottomLabel.text = @"详情";
    
    _rightItem.image = [UIImage imageNamed:@"common_rightItem"];
}

-(void)setAnnouncement:(WFYAnnouncementModel *)announcement{
    _announcement=announcement;
    
    _topLabel.text =  [WFYTimeTool timeStr:[announcement.timeStamp longLongValue]];
    _topLabel.frame = announcement.topFrame;
    _topLabel.layer.masksToBounds = YES;
    _topLabel.layer.cornerRadius =3.f;
    
    self.mTitleLabel.text = announcement.anncTopic;
    [WFHTTPTOOL getUserInfoByUserID:announcement.anncPublisher
                         completion:^(RCUserInfo *user) {
                             self.publisherLabel.text = user.name;
                         }];
    if ([announcement.anncPicURL length]>0) {
        //程序出现bug，图片一直显示不出来，后来跟踪到url为nil
        //This method expects URLString to contain any necessary percent escape codes, which are ‘:’, ‘/’, ‘%’, ‘#’, ‘;’, and ‘@’. Note that ‘%’ escapes are translated via UTF-8.
        //stringByReplacingOccurrencesOfString 可以解决这个问题
//        NSString *str = [announcement.anncPicURL stringByReplacingOccurrencesOfString:@" " withString:@""];
//        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSURL *url = [NSURL URLWithString:str];
        [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[announcement.anncPicURL WFYURLString]]
                           placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      NSLog(@"%@",error);
                                  }];
    }
    self.descLabel.text = announcement.anncSummary;
    self.boxView.frame = announcement.boxViewFrame;
    self.mTitleLabel.frame = announcement.titleFrame;
    self.publisherLabel.frame = announcement.publisherFrame;
    self.mImageView.frame = announcement.imageFrame;
    self.descLabel.frame = announcement.descFrame;
    self.line.frame = announcement.lineFrame;
    self.bottomLabel.frame =announcement.bottomLabelFrame;
    self.rightItem.frame = announcement.rightItemFrame;
}
 
- (void) willMoveToSuperview:(UIView *)newSuperview{
    UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(changeColor:)];
    tapRecognizer.minimumPressDuration = 0;
    tapRecognizer.cancelsTouchesInView = NO;
    tapRecognizer.delegate = self;
    [self.boxView addGestureRecognizer:tapRecognizer];
}

- (void)changeColor:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.boxView.backgroundColor = RGB(215, 215 , 215);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.boxView.backgroundColor = RGB(255, 255, 255);
    }
}

//下面三个函数用于多个GestureRecognizer 协同作业，避免按下的手势影响了而别的手势不响应
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

/*
 - (void)layoutUI
 {
 CGFloat cellW = self.bounds.size.width;
 CGFloat cellH = self.bounds.size.height;
 //topLabel
 CGFloat topLabelW = cellW* 0.4;
 CGFloat topLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT)
 withFont:[UIFont systemFontOfSize:[AppFontMgr standardFontSize]]].height;
 CGFloat topLabelX = (cellW-topLabelW) * 0.5;
 CGFloat topLabelY = 0;
 _topLabel.frame = CGRectMake(topLabelX, topLabelY, topLabelW, topLabelH);
 _topLabel.layer.masksToBounds = YES;
 _topLabel.layer.cornerRadius =topLabelH/5;
 //boxView
 CGFloat boxViewW = cellW * 0.9;
 CGFloat boxViewX = (cellW-boxViewW) * 0.5;
 CGFloat marginboxViewToLeft = boxViewX;
 CGFloat boxViewY = CGRectGetMaxY(_topLabel.frame) + marginboxViewToLeft;
 CGFloat boxViewH = cellH - marginboxViewToLeft - topLabelH;
 _boxView.frame = CGRectMake(boxViewX, boxViewY, boxViewW, boxViewH);
 //mTitleLabel
 CGFloat titleLabelX = marginboxViewToLeft;
 CGFloat titleLabelY = marginboxViewToLeft;
 CGFloat titleLabelW = boxViewW- 2 * marginboxViewToLeft;
 CGFloat titleLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_mTitleLabel.font].height;
 _mTitleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
 //publisherLabel
 CGFloat publisherLabelX = CGRectGetMinX(_mTitleLabel.frame);
 CGFloat publisherLabelW = titleLabelW;
 CGFloat publisherLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_publisherLabel.font].height;
 CGFloat marginImageViewToLabel =publisherLabelH* 0.6;
 CGFloat publisherLabelY = CGRectGetMaxY(_mTitleLabel.frame)+marginImageViewToLabel;
 _publisherLabel.frame = CGRectMake(publisherLabelX, publisherLabelY, publisherLabelW, publisherLabelH);
 //bottomLabel
 CGFloat bottomLabelX = CGRectGetMinX(_mTitleLabel.frame);
 CGFloat bottomLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_bottomLabel.font].height;
 CGFloat bottomLabelY = boxViewH - bottomLabelH*1.5;
 CGFloat bottomLabelW = titleLabelW;
 _bottomLabel.frame =CGRectMake(bottomLabelX, bottomLabelY, bottomLabelW, bottomLabelH);
 //rightItem
 CGFloat marginRightItemToRight = marginboxViewToLeft;
 CGFloat rightItemH = bottomLabelH;
 CGFloat rightItemY = bottomLabelY;
 CGFloat rightItemW = rightItemH;
 CGFloat rightItemX = boxViewW - marginRightItemToRight - rightItemW;
 _rightItem.frame = CGRectMake(rightItemX, rightItemY, rightItemW, rightItemH);
 //line
 CGFloat lineX = CGRectGetMinX(_mTitleLabel.frame);
 CGFloat lineH = 1;
 CGFloat lineY = CGRectGetMinY(_rightItem.frame)-marginImageViewToLabel-lineH;
 CGFloat lineW = titleLabelW;
 _line.frame = CGRectMake(lineX, lineY, lineW, lineH);
 //descLabel
 CGFloat descLabelX = CGRectGetMinX(_mTitleLabel.frame);
 CGFloat descLabelW = titleLabelW;
 CGFloat descLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:_descLabel.font].height;
 CGFloat descLabelY = CGRectGetMinY(_line.frame)-marginImageViewToLabel-descLabelH;
 _descLabel.frame = CGRectMake(descLabelX, descLabelY, descLabelW, descLabelH);
 //mImageView
 CGFloat imageViewX = CGRectGetMinX(_mTitleLabel.frame);
 CGFloat imageViewW = titleLabelW;
 CGFloat imageViewY = CGRectGetMaxY(_publisherLabel.frame)+marginImageViewToLabel;
 CGFloat imageViewH = CGRectGetMinY(_descLabel.frame)-CGRectGetMaxY(_publisherLabel.frame)- 2 * marginImageViewToLabel;
 _mImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
 }
 */

@end


