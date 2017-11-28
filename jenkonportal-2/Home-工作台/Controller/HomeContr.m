//
//  WorkbenchContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/8.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "HomeContr.h"
#import "AppFontMgr.h"
#import "SVProgressHUD.h"
#import "WebViewContr.h"

@interface HomeContr_GroupItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *imgName;
@end

// 组头
@interface HomeContr_GroupHeader : UIView
@property (weak, nonatomic) UILabel *title;
@end

// 组项
@interface HomeContr_GroupBodyCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *mImageView;
@property (weak, nonatomic) UILabel *mTitle;
@end

#define reuserID @"HomeContr_GroupBodyCell"

@interface HomeContr ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation HomeContr
{
    CGFloat _collectionViewLeftMargin;
    CGFloat _collectionViewCellW;
    
    UIView *_scrollView;
    HomeContr_GroupHeader *_header_0;
    UICollectionView *_body_0;
    UIView *_line_0;
    
    HomeContr_GroupHeader *_header_1;
    UICollectionView *_body_1;
    UIView *_line_1;
    
    HomeContr_GroupHeader *_header_2;
    UICollectionView *_body_2;
    UIView *_line_2;
    
    HomeContr_GroupHeader *_header_3;
    UICollectionView *_body_3;
    UIView *_line_3;
    
    NSArray<NSMutableArray<HomeContr_GroupItem *> *> *_groupItems;
    
    UIImageView *_faker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)initIvar
{
    _collectionViewLeftMargin = SCREEN_WIDTH/20;
    CGFloat collectionViewCellMargin = 1.5*_collectionViewLeftMargin;
    _collectionViewCellW = (SCREEN_WIDTH-2*_collectionViewLeftMargin-3*collectionViewCellMargin)/4;
    
    NSArray *titles = @[
                        @[@"排班管理", @"预约管理", @"工作量统计", @"绩效考核", @"患者管理", @"病历查询", @"门诊量统计", @"危机值"],
                        @[@"流程审批", @"会议记录", @"待办任务", @"请假申请", @"知识库", @"文件管理", @"邮件助手", @"合同管理"],
                        @[@"随访系统", @"CRM系统", @"健康管理"]
                        ];
    
    NSMutableArray *imgNames = [@[] mutableCopy];
    __block NSInteger imgIdx = 0;
    [titles enumerateObjectsUsingBlock:^(NSArray *  _Nonnull arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *sectionArr = [@[] mutableCopy];
        for (NSInteger i = 0; i<arr.count; i++) {
            [sectionArr addObject:[NSString stringWithFormat:@"home_cell_%ld", imgIdx]];
            imgIdx++;
        }
        [imgNames addObject:sectionArr];
    }];
    
    NSMutableArray *items = [@[] mutableCopy];
    
    for (NSInteger i = 0; i<titles.count; i++) {
        NSArray *sectionTitles = titles[i];
        NSArray *sectionImgNames = imgNames[i];
        
        NSMutableArray *sectionItems = [@[] mutableCopy];
        for (NSInteger j = 0; j<sectionTitles.count; j++) {
            HomeContr_GroupItem *item = [[HomeContr_GroupItem alloc] init];
            item.title = sectionTitles[j];
            item.imgName = sectionImgNames[j];
            [sectionItems addObject:item];
        }
        [items addObject:sectionItems];
        
    }
    
    _groupItems = items;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI
{
    _scrollView = [[UIView alloc] init];
    _header_0 = [[HomeContr_GroupHeader alloc] init];
    _body_0 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_0 = [[UIView alloc] init];
    _header_1 = [[HomeContr_GroupHeader alloc] init];
    _body_1 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_1 = [[UIView alloc] init];

    _header_2 = [[HomeContr_GroupHeader alloc] init];
    _body_2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_2 = [[UIView alloc] init];
    
    _faker = [[UIImageView alloc] init];
    
    
    
    [self.view addSubview:_scrollView];
    
    [_scrollView addSubview:_faker];
    
    [_scrollView addSubview:_header_0];
    [_scrollView addSubview:_body_0];
    [_scrollView addSubview:_line_0];
    [_scrollView addSubview:_header_1];
    [_scrollView addSubview:_body_1];
    [_scrollView addSubview:_line_1];
    [_scrollView addSubview:_header_2];
    [_scrollView addSubview:_body_2];
    [_scrollView addSubview:_line_2];

}

- (void)bindUIValue
{
    self.title = @"工作台";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
//    _scrollView.alwaysBounceVertical = YES;
    
    _header_0.title.text = @"医疗办公";
    
    [_body_0 registerClass:[HomeContr_GroupBodyCell class] forCellWithReuseIdentifier:reuserID];
//    _body_0.layer.masksToBounds = NO;
    _body_0.backgroundColor = [UIColor clearColor];
    _body_0.dataSource = self;
    _body_0.delegate = self;
    UILongPressGestureRecognizer *longPresss_0 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_body_0 addGestureRecognizer:longPresss_0];

    
    _line_0.backgroundColor = RGB(240, 240, 240);
    
    _header_1.title.text = @"行政办公";
    
    [_body_1 registerClass:[HomeContr_GroupBodyCell class] forCellWithReuseIdentifier:reuserID];
//    _body_1.layer.masksToBounds = NO;
    _body_1.backgroundColor = [UIColor clearColor];
    _body_1.dataSource = self;
    _body_1.delegate = self;
    UILongPressGestureRecognizer *longPresss_1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_body_1 addGestureRecognizer:longPresss_1];


    _line_1.backgroundColor = RGB(240, 240, 240);
    
    _header_2.title.text = @"其它系统";
    
    [_body_2 registerClass:[HomeContr_GroupBodyCell class] forCellWithReuseIdentifier:reuserID];
//    _body_2.layer.masksToBounds = NO;
    _body_2.backgroundColor = [UIColor clearColor];
    _body_2.dataSource = self;
    _body_2.delegate = self;
    UILongPressGestureRecognizer *longPresss_2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_body_2 addGestureRecognizer:longPresss_2];
    
    _line_2.backgroundColor = RGB(240, 240, 240);
    
    _faker.image = [UIImage imageNamed:@"faker_workbench"];
    _faker.hidden = YES;
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat scrollX = 0, scrollY = 0, scrollW = sw, scrollH = sh-kTabBarH;
    _scrollView.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    
    CGFloat headerTopMarginToNaviBotm = sh*0.025;
    CGFloat headerX = 0, headerY_0 = headerTopMarginToNaviBotm, headerW = sw, headerH = sh*0.03;//kStatusBarH+kNaviBarH+
    _header_0.frame = CGRectMake(headerX, headerY_0, headerW, headerH);
    
    CGFloat bodyW = (sw-2*_collectionViewLeftMargin), bodyH = bodyW*0.45, bodyX = _collectionViewLeftMargin, bodyY_0 = headerY_0+headerH;
    _body_0.frame = CGRectMake(bodyX, bodyY_0, bodyW, bodyH);
    
    CGFloat lineW = sw, lineH = 1, lineX = 0, lineY_0 = bodyY_0+bodyH;
    _line_0.frame = CGRectMake(lineX, lineY_0, lineW, lineH);
    
    CGFloat headerY_1 = lineY_0+lineH+headerTopMarginToNaviBotm;
    _header_1.frame = CGRectMake(headerX, headerY_1, headerW, headerH);
    
    CGFloat bodyY_1 = headerY_1+headerH;
    _body_1.frame = CGRectMake(bodyX, bodyY_1, bodyW, bodyH);
    
    CGFloat lineY_1 = bodyY_1+bodyH;
    _line_1.frame = CGRectMake(lineX, lineY_1, lineW, lineH);
    
    CGFloat headerY_2 = lineY_1+lineH+headerTopMarginToNaviBotm;
    _header_2.frame = CGRectMake(headerX, headerY_2, headerW, headerH);
    
    CGFloat bodyY_2 = headerY_2+headerH;
    _body_2.frame = CGRectMake(bodyX, bodyY_2, bodyW, bodyH);
    
    CGFloat lineY_2 = bodyY_2+bodyH;
    _line_2.frame = CGRectMake(lineX, lineY_2, lineW, lineH);
    
    CGFloat fakerTopMargin = kStatusBarH+kNaviBarH;
    CGFloat fakerH = sh-kStatusBarH-kNaviBarH-kTabBarH;
    _faker.frame = CGRectMake(0, fakerTopMargin, sw, fakerH);
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    UICollectionView *collectionView = (UICollectionView *)gesture.view;
    
    // 判断手势状态
    switch (gesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            // 判断手势落点位置是否在路径上(长按cell时,显示对应cell的位置,如path = 1 - 0,即表示长按的是第1组第0个cell). 点击除了cell的其他地方皆显示为null
            NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:[gesture locationInView:collectionView]];
            // 如果点击的位置不是cell,break
            if (nil == indexPath) {
                break;
            }
            
            // 在路径上则开始移动该路径上的cell
            [collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            // 移动过程当中随时更新cell位置
            [collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:collectionView]];
            break;
            
        case UIGestureRecognizerStateEnded:
            // 移动结束后关闭cell移动
            [collectionView endInteractiveMovement];
            break;
        default:
            [collectionView cancelInteractiveMovement];
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray<HomeContr_GroupItem *> *dataSource = _groupItems[0];
    // 取出来源组
    HomeContr_GroupItem *sourceItem = dataSource[sourceIndexPath.row];
    // 取出目标组
//    HomeContr_GroupItem *destinationItem = dataSource[destinationIndexPath.row];
    
    // 从资源数组中移除该数据
    [dataSource removeObject:sourceItem];
    // 将数据插入到资源数组中的目标位置上
    [dataSource insertObject:sourceItem atIndex:destinationIndexPath.row];
}

#pragma mark - UICollectionViewDataSource

/**
 * 返回组数
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

/**
 * 返回组的行数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView==_body_0) {
        return _groupItems[0].count;
    }else if (collectionView==_body_1) {
        return _groupItems[1].count;
    }else if (collectionView==_body_2) {
        return _groupItems[2].count;
    }
    return 0;
}

/**
 * 返回indexPath对应的cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeContr_GroupBodyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserID forIndexPath:indexPath];
    NSArray<HomeContr_GroupItem *> *dataSource = nil;
    if (collectionView==_body_0) {
        dataSource = _groupItems[0];
    }else if (collectionView==_body_1) {
        dataSource = _groupItems[1];
    }else if (collectionView==_body_2) {
        dataSource = _groupItems[2];
    }
    cell.mTitle.text = dataSource[indexPath.row].title;
    cell.mImageView.image = [UIImage imageNamed:dataSource[indexPath.row].imgName];
    return cell;
}

#pragma mark - UICollectionViewDelegate

/**
 * 可截获cell的选择
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/**
 * 选择cell之后回调方法
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<HomeContr_GroupItem *> *dataSource = nil;
    if (collectionView==_body_0) {
        dataSource = _groupItems[0];
    }else if (collectionView==_body_1) {
        dataSource = _groupItems[1];
    }else if (collectionView==_body_2) {
        dataSource = _groupItems[2];
    }

    WebViewContr *c = [[WebViewContr alloc] init];
    c.title = dataSource[indexPath.row].title;
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

/**
 * layout:返回indexPath对应cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_collectionViewCellW, _collectionViewCellW);
}

@end


@implementation HomeContr_GroupHeader
{
    UIView *_item;
}

- (instancetype)init
{
    if (self = [super init]) {
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
    _item = [[UIView alloc] init];
    [self addSubview:_item];
    
    UILabel *title = [[UILabel alloc] init];
    [self addSubview:title];
    _title = title;
}

- (void)bindUIValue
{
    _item.backgroundColor = RGB(0, 90, 119);
    
    _title.textColor = [UIColor grayColor];
    _title.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat itemLeftMargin = w/30;
    CGFloat itemW = itemLeftMargin/3, itemH = h*0.6, itemX = itemLeftMargin, itemY = (h-itemH)/2;
    _item.frame = CGRectMake(itemX, itemY, itemW, itemH);
    
    CGFloat titleLeftMarginToItemRight = itemW;
    CGFloat titleW = w/3, titleH = h, titleX = itemX+itemW+titleLeftMarginToItemRight, titleY = 0;
    _title.frame = CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutUI];
    [self bindUIValue2];
}

- (void)bindUIValue2
{
    _item.layer.masksToBounds = YES;
    _item.layer.cornerRadius = _item.frame.size.width/3;
}

@end


@implementation HomeContr_GroupBodyCell
{
    UIView *_bg;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
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
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *title = [[UILabel alloc] init];
    _bg = [[UIView alloc] init];
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:title];
    [self.contentView insertSubview:_bg atIndex:0];
    
    _mImageView = imageView;
    _mTitle = title;
}

- (void)bindUIValue
{
    _bg.layer.masksToBounds = YES;
    _bg.layer.cornerRadius = SCREEN_WIDTH/36;
    _bg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    _mTitle.textAlignment = NSTextAlignmentCenter;
    _mTitle.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat titleW = w, titleH = h*0.2, titleX = 0, titleY = h-titleH;
    _mTitle.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat imageViewW = h*0.5, imageViewH = imageViewW, imageViewX = (w-imageViewW)/2, imageViewY = (h-titleH-imageViewH)/2;
    _mImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    
    _bg.frame = self.bounds;
}

@end


@implementation HomeContr_GroupItem

@end
