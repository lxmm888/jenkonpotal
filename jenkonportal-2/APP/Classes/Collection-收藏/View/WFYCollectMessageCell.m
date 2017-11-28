//
//  WFYCollectMessageCell.m
//  jenkonportal
//
//  Created by 赵立 on 2017/11/16.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYCollectMessageCell.h"
#import "WFYCollectionModel.h"
#import "WFYCollectionModel.h"
#import "UIImageView+WebCache.h"
#import "NSString+Kit.h"

#define kStandardFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]]
#define kTextLabelFont [UIFont systemFontOfSize:[AppFontMgr standardFontSize]+2]
#define kExtraLabelFont [UIFont boldSystemFontOfSize:[AppFontMgr standardFontSize]-1]

#define kMaxWidth [UIScreen mainScreen].bounds.size.width - (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 - 35

@interface WFYCollectMessageCell()

/** 模型*/
@property (nonatomic,strong) WFYCollectionModel *collection;

@end

@implementation WFYCollectMessageCell

/*!
 自定义消息 Cell 的 Size
 @param model               要显示的消息model
 @param collectionViewWidth cell所在的collectionView的宽度
 @param extraHeight         cell内容区域之外的高度
 
 @return 自定义消息Cell的Size
 
 @discussion 当应用自定义消息时，必须实现该方法来返回cell的Size。
 其中，extraHeight是Cell根据界面上下文，需要额外显示的高度（比如时间、用户名的高度等）。
 一般而言，Cell的高度应该是内容显示的高度再加上extraHeight的高度。
 */

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    WFYCollectMessage *message = (WFYCollectMessage *)model.content;
    CGSize size = [WFYCollectMessageCell getBubbleBackgroundViewSize:message];
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.textLabel setFont:kTextLabelFont];
    self.textLabel.numberOfLines = 0;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textLabel setTextColor:[UIColor blackColor]];
    [self.bubbleBackgroundView addSubview:self.textLabel];
    
    self.extraLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.extraLabel setFont:kExtraLabelFont];
    self.extraLabel.numberOfLines = 3;
    [self.extraLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.extraLabel setTextAlignment:NSTextAlignmentLeft];
    [self.extraLabel setTextColor:[UIColor grayColor]];
    [self.bubbleBackgroundView addSubview:self.extraLabel];
    
    self.picView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:self.picView];
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *textMessageTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textMessageTap.numberOfTapsRequired = 1;
    textMessageTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:textMessageTap];
    
//    [self.textLabel addGestureRecognizer:textMessageTap];
//    self.textLabel.userInteractionEnabled = YES;
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    [self setAutoLayout];
}

//懒加载
-(WFYCollectionModel *)collection{
    if (!_collection) {
        WFYCollectMessage *collectMessage = (WFYCollectMessage *)self.model.content;
        //从数据库获取收藏内容
        _collection = [[WFDataBaseManager shareInstance]getCollectionByCollectionId:collectMessage.collectionId];
    }
    return _collection;
}

- (void)setAutoLayout {
    WFYCollectMessage *collectMessage = (WFYCollectMessage *)self.model.content;
    CGSize textLabelSize = [[self class] getTextLabelSize:collectMessage];
    CGFloat extraLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kExtraLabelFont].height * 3;
    if (collectMessage) {
        self.textLabel.text = collectMessage.content;
        if ([self.collection.collectionPicURL length]>0) {
            textLabelSize.width = kMaxWidth+5;
            [self.picView sd_setImageWithURL:[NSURL URLWithString:[self.collection.collectionPicURL WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
            self.extraLabel.text = self.collection.collectionDesc;
        }
    }
    
    //CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    CGSize bubbleBackgroundViewSize = CGSizeZero;//聊天泡泡的Size
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    //拉伸图片
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.textLabel.frame = CGRectMake(20, 7, textLabelSize.width, textLabelSize.height);
        if ([self.collection.collectionPicURL length]>0) {
            self.extraLabel.frame = CGRectMake(CGRectGetMinX(self.textLabel.frame),
                                               CGRectGetMaxY(self.textLabel.frame)+HeadAndContentSpacing,
                                               textLabelSize.width-extraLabelH-HeadAndContentSpacing,
                                               extraLabelH);
            
            self.picView.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame)-extraLabelH,
                                            CGRectGetMinY(self.extraLabel.frame),
                                            extraLabelH,
                                            extraLabelH);
            bubbleBackgroundViewSize = [[self class] getBubbleSize:CGSizeMake(textLabelSize.width, textLabelSize.height+HeadAndContentSpacing+extraLabelH)];
        }
        else{
            bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
        }
        
        
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame =
        CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
        [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                            image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        self.textLabel.frame = CGRectMake(12, 7, textLabelSize.width, textLabelSize.height);
        if ([self.collection.collectionPicURL length]>0) {
            self.extraLabel.frame = CGRectMake(CGRectGetMinX(self.textLabel.frame),
                                               CGRectGetMaxY(self.textLabel.frame)+HeadAndContentSpacing,
                                               textLabelSize.width-extraLabelH-HeadAndContentSpacing,
                                               extraLabelH);
            
            self.picView.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame)-extraLabelH,
                                            CGRectGetMinY(self.extraLabel.frame),
                                            extraLabelH,
                                            extraLabelH);
            bubbleBackgroundViewSize = [[self class] getBubbleSize:CGSizeMake(textLabelSize.width, textLabelSize.height+HeadAndContentSpacing+extraLabelH)];
        }
        else{
            bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
        }
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                  [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame =
        CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
        [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                            image.size.height * 0.2, image.size.width * 0.8)];
    }
    [self.extraLabel sizeToFit];
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

+ (CGSize)getTextLabelSize:(WFYCollectMessage *)message {
    if ([message.content length] > 0) {
        float maxWidth = kMaxWidth;
        CGRect textRect = [message.content
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName : kTextLabelFont}
                           context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getBubbleSize:(CGSize)contentViewSize {
    CGSize bubbleSize = CGSizeMake(contentViewSize.width, contentViewSize.height);
    
    if (bubbleSize.width + 12 + 20 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 20;
    } else {
        bubbleSize.width = 50;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(WFYCollectMessage *)message {
    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    //从数据库获取收藏内容,类方法中不能使用实例对象
    WFYCollectionModel *model  = [[WFDataBaseManager shareInstance]getCollectionByCollectionId:message.collectionId];
    if ([model.collectionPicURL length]>0) {
        CGFloat extraLabelH = [@"" sizeThatFit:CGSizeMake(MAXFLOAT, MAXFLOAT) withFont:kExtraLabelFont].height * 3;
        //有图片的时候宽度不应该以textLabelSize.width为准，如果标题内容少，图片和描述信息就会“挤”在一起
        //return [[self class] getBubbleSize:CGSizeMake(textLabelSize.width, textLabelSize.height+HeadAndContentSpacing+extraLabelH)];
        return [[self class] getBubbleSize:CGSizeMake(kMaxWidth+5,textLabelSize.height+HeadAndContentSpacing+extraLabelH)];
    }
    else{
        return [[self class] getBubbleSize:textLabelSize];
    }
}

@end
