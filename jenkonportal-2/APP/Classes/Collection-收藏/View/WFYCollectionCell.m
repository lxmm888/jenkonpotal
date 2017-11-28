//
//  WFYCollectionCell.m
//  FamilyDrPerVer
//
//  Created by 冯文林 on 16/10/11.
//  Copyright © 2016年 jetsun. All rights reserved.
//

#import "WFYCollectionCell.h"
#import "NSString+Kit.h"
#import "AppFontMgr.h"
#import "XICommonDef.h"
#import "WFYCollectionModel.h"
#import "UIImageView+WebCache.h"

@interface WFYCollectionCell()

@property (weak, nonatomic) UILabel *sourceLabel;
@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitleLabel;
@property (weak, nonatomic) UILabel *descLabel;

@end

@implementation WFYCollectionCell

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
    UILabel *sourceLabel = [[UILabel alloc] init];
    UILabel *timeLabel = [[UILabel alloc]init];
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    UILabel *descLabel = [[UILabel alloc] init];
    
    [self addSubview:sourceLabel];
    [self addSubview:timeLabel];
    [self addSubview:imageView];
    [self addSubview:titleLabel];
    [self addSubview:descLabel];
 
    _sourceLabel = sourceLabel;
    _timeLabel = timeLabel;
    _mImageView = imageView;
    _mTitleLabel = titleLabel;
    _descLabel = descLabel;
}

- (void)bindUIValue
{
    _sourceLabel.textAlignment = NSTextAlignmentLeft;
    _sourceLabel.font = kStandardFont;
    _sourceLabel.textColor = RGB(146, 144, 144);
    
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.font = kTimeLabelFont;
    _timeLabel.textColor = RGB(146, 144, 144);
    
    _mTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mTitleLabel.font =kTitleLabelFont;
    _mTitleLabel.textColor = RGB(54, 54, 54);
    
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.font = kStandardFont;
    _descLabel.textColor = RGB(146, 144, 144);
}

-(void)setCollection:(WFYCollectionModel *)collection{
    _collection = collection;
    
    _sourceLabel.text = collection.collectionSourceName;
    _timeLabel.text = [WFYTimeTool timeStr:[collection.timeStamp longLongValue]];
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:[collection.collectionPicURL WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
    _mTitleLabel.text = collection.collectionTitle;
    _descLabel.text = collection.collectionDesc;
    
    _sourceLabel.frame = collection.sourceLabelFrame;
    _timeLabel.frame = collection.timeLabelFrame;
    _mImageView.frame = collection.imageViewFrame;
    _mTitleLabel.frame = collection.titleFrame;
    _descLabel.frame = collection.descFrame;
}



@end
