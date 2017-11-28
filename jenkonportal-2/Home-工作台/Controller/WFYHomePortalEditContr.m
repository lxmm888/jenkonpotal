//
//  WFYHomePortalEditContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomePortalEditContr.h"
#import "AppFontMgr.h"
#import "SVProgressHUD.h"
#import "WebViewContr.h"
#import "WFYHomePortalHeader.h"
#import "WFYHomePortalItem.h"
#import "WFHttpTool.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "WFYHomePortalEditCell.h"
#import "WFDataBaseManager.h"
#import "AppConf.h"

#define reuserID_PortalEditCell @"HomeContr_PortalEditCell"

#define kBodyH(x) (SCREEN_WIDTH-2*SCREEN_WIDTH/20)* 0.21 * ((_groupItems[x].count + 4 -1)/ 4)

@interface WFYHomePortalEditContr ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property(nonatomic,assign) enum CellState;
@end

@implementation WFYHomePortalEditContr
{
    CGFloat _collectionViewLeftMargin;
    CGFloat _collectionViewCellW;
    CGFloat _freqCollectionViewCellW;
    
    CGFloat _freqCollectionViewRow;
    
    UIScrollView *_scrollView;
    
    WFYHomePortalHeader *_freqHeader;
    UICollectionView *_freqCollectionView;
    UIView *_freqLine;
    UIButton *_freBtn;
    
    WFYHomePortalHeader *_header_0;
    UICollectionView *_body_0;
    UIView *_line_0;
    
    WFYHomePortalHeader *_header_1;
    UICollectionView *_body_1;
    UIView *_line_1;
    
    WFYHomePortalHeader *_header_2;
    UICollectionView *_body_2;
    UIView *_line_2;
    
    WFYHomePortalHeader *_header_3;
    UICollectionView *_body_3;
    UIView *_line_3;
    
    NSArray<NSMutableArray<WFYHomePortalItem *> *> *_groupItems;
    
    NSMutableArray<WFYHomePortalItem *> *_freqUseItems;
    
    UIImageView *_faker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self bindUIValue2];
}

- (void)initIvar
{
    _collectionViewLeftMargin = SCREEN_WIDTH/20;
    
    CGFloat collectionViewCellMargin = 1.5*_collectionViewLeftMargin;
    _collectionViewCellW = (SCREEN_WIDTH-2*_collectionViewLeftMargin-3*collectionViewCellMargin)/4;
    
    CGFloat freqCollectionViewCellMargin = 0.2*_collectionViewLeftMargin;
    _freqCollectionViewCellW = (SCREEN_WIDTH-2*_collectionViewLeftMargin-11*freqCollectionViewCellMargin)/12;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI
{
    _scrollView = [[UIScrollView alloc] init];
    
    _freqHeader = [[WFYHomePortalHeader alloc] init];
    
    
    _freqCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _freqLine = [[UIView alloc] init];
    _freBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _header_0 = [[WFYHomePortalHeader alloc] init];
    _body_0 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_0 = [[UIView alloc] init];
    
    _header_1 = [[WFYHomePortalHeader alloc] init];
    _body_1 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_1 = [[UIView alloc] init];
    
    _header_2 = [[WFYHomePortalHeader alloc] init];
    _body_2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _line_2 = [[UIView alloc] init];
    
    _faker = [[UIImageView alloc] init];
    
    [self.view addSubview:_freqHeader];
    [self.view addSubview:_freqCollectionView];
    [self.view addSubview:_freqLine];
    [self.view addSubview:_freBtn];
    [self.view addSubview:_scrollView];
    
    [_scrollView addSubview:_header_0];
    [_scrollView addSubview:_body_0];
    [_scrollView addSubview:_line_0];
    [_scrollView addSubview:_header_1];
    [_scrollView addSubview:_body_1];
    [_scrollView addSubview:_line_1];
    [_scrollView addSubview:_header_2];
    [_scrollView addSubview:_body_2];
    [_scrollView addSubview:_line_2];
    
    [_scrollView addSubview:_faker];
}

- (void)bindUIValue
{
    self.title = @"更多";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //    _scrollView.alwaysBounceVertical = YES;
    
    _scrollView.delegate =self;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    NSMutableAttributedString *str =[[NSMutableAttributedString alloc]initWithString:@"我的常用(按住拖动图标排序)"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 4)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(4, 10)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1] range:NSMakeRange(0, 4)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3] range:NSMakeRange(4, 10)];
    _freqHeader.title.attributedText =str;
    
    [_freqCollectionView registerClass:[WFYHomePortalEditCell class] forCellWithReuseIdentifier:reuserID_PortalEditCell];
    //    _body_0.layer.masksToBounds = NO;
    _freqCollectionView.backgroundColor = [UIColor clearColor];
    _freqCollectionView.dataSource = self;
    _freqCollectionView.delegate = self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 1.0;
    [_freqCollectionView addGestureRecognizer:longPress];
    _freqCollectionView.showsVerticalScrollIndicator = NO;
    
    _freqLine.backgroundColor = RGB(240, 240, 240);
    
    [_freBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_freBtn setTitleColor:RGB(0, 91, 242) forState:UIControlStateNormal];
    _freBtn.titleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
    [_freBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _header_0.title.text = @"医疗办公";
    
    [_body_0 registerClass:[WFYHomePortalEditCell class] forCellWithReuseIdentifier:reuserID_PortalEditCell];
    //    _body_0.layer.masksToBounds = NO;
    _body_0.backgroundColor = [UIColor clearColor];
    _body_0.dataSource = self;
    _body_0.delegate = self;
    
    
    _line_0.backgroundColor = RGB(240, 240, 240);
    
    _header_1.title.text = @"行政办公";
    
    [_body_1 registerClass:[WFYHomePortalEditCell class] forCellWithReuseIdentifier:reuserID_PortalEditCell];
    //    _body_1.layer.masksToBounds = NO;
    _body_1.backgroundColor = [UIColor clearColor];
    _body_1.dataSource = self;
    _body_1.delegate = self;
    
    _line_1.backgroundColor = RGB(240, 240, 240);
    
    _header_2.title.text = @"其它系统";
    
    [_body_2 registerClass:[WFYHomePortalEditCell class] forCellWithReuseIdentifier:reuserID_PortalEditCell];
    //    _body_2.layer.masksToBounds = NO;
    _body_2.backgroundColor = [UIColor clearColor];
    _body_2.dataSource = self;
    _body_2.delegate = self;
    
    _line_2.backgroundColor = RGB(240, 240, 240);
    
    _faker.image = [UIImage imageNamed:@"faker_workbench"];
    _faker.hidden = YES;
}

- (void)bindUIValue2{
    if (_freqUseItems.count<1) {
        [self loadFreqUseItem];
    }
    if (_groupItems.count<1) {
        [self loadPortalItem];
    }
    
    CGFloat sizeY = _line_2.frame.origin.y+kStatusBarH;
    _scrollView.contentSize = CGSizeMake(0, sizeY);
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat headerTopMarginToNaviBotm = sh*0.025;
    
    CGFloat headerX = 0, freqHeaderY = headerTopMarginToNaviBotm, headerW = sw, headerH = sh*0.03;
    _freqHeader.frame = CGRectMake(headerX, freqHeaderY, headerW, headerH);
    
    CGFloat freqBtnW=50,freqBtnX= sw-_collectionViewLeftMargin-freqBtnW;
    _freBtn.frame = CGRectMake(freqBtnX, freqHeaderY, freqBtnW, headerH);
    
    CGFloat bodyW = (sw-2*_collectionViewLeftMargin), bodyH = bodyW*0.45, bodyX = _collectionViewLeftMargin, freqViewY = freqHeaderY+headerH;
    CGFloat freqViewH = bodyH;//_freqCollectionView.collectionViewLayout.collectionViewContentSize.height;
    _freqCollectionView.frame = CGRectMake(bodyX, freqViewY, bodyW, freqViewH);
    
    CGFloat lineW = sw, lineH = 1, lineX = 0, freqLineY = freqViewY+freqViewH;
    _freqLine.frame = CGRectMake(lineX, freqLineY, lineW, lineH);
    
    CGFloat scrollX = 0, scrollY = freqLineY+lineH, scrollW = sw, scrollH = sh-kTabBarH-CGRectGetMaxY(_freqLine.frame);
    _scrollView.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    
    CGFloat headerY_0 = headerTopMarginToNaviBotm;
    _header_0.frame = CGRectMake(headerX, headerY_0, headerW, headerH);
    
    CGFloat bodyY_0 = headerY_0+headerH,bodyH_0 = kBodyH(0);
    _body_0.frame = CGRectMake(bodyX, bodyY_0, bodyW, bodyH_0);
    
    CGFloat lineY_0 = bodyY_0+bodyH_0;
    _line_0.frame = CGRectMake(lineX, lineY_0, lineW, lineH);
    
    CGFloat headerY_1 = lineY_0+lineH+headerTopMarginToNaviBotm;
    _header_1.frame = CGRectMake(headerX, headerY_1, headerW, headerH);
    
    CGFloat bodyY_1 = headerY_1+headerH,bodyH_1 = kBodyH(1);
    _body_1.frame = CGRectMake(bodyX, bodyY_1, bodyW, bodyH_1);
    
    CGFloat lineY_1 = bodyY_1+bodyH_1;
    _line_1.frame = CGRectMake(lineX, lineY_1, lineW, lineH);
    
    CGFloat headerY_2 = lineY_1+lineH+headerTopMarginToNaviBotm;
    _header_2.frame = CGRectMake(headerX, headerY_2, headerW, headerH);
    
    CGFloat bodyY_2 = headerY_2+headerH,bodyH_2 = kBodyH(2);
    _body_2.frame = CGRectMake(bodyX, bodyY_2, bodyW, bodyH_2);
    
    CGFloat lineY_2 = bodyY_2+bodyH_2;
    _line_2.frame = CGRectMake(lineX, lineY_2, lineW, lineH);
    
    CGFloat fakerTopMargin = kStatusBarH+kNaviBarH;
    CGFloat fakerH = sh-kStatusBarH-kNaviBarH-kTabBarH;
    _faker.frame = CGRectMake(0, fakerTopMargin, sw, fakerH);
}

- (void)setFreqCollectionView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_freqCollectionView reloadData];
        [self layoutUI];
        if (_freqCollectionViewRow==_freqUseItems.count-1) {
            [_freqCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_freqCollectionViewRow inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:YES];
        }
    });
}

- (void)loadFreqUseItem{
    _freqUseItems=[[WFDataBaseManager shareInstance]getHomePortalItem];
    if (_freqUseItems.count >0) {
        [_freqUseItems removeLastObject];
    }
    [self setFreqCollectionView];
}

- (void)loadPortalItem{
    NSMutableArray *items = [@[] mutableCopy];
    [items addObject:[@[] mutableCopy]];
    [items addObject:[@[] mutableCopy]];
    [items addObject:[@[] mutableCopy]];
    [WFHTTPTOOL getHomePortalWithDefaultFlag:@"0"
                                       Block:^(NSArray *result) {
                                           // 字典数组 -> 模型数组
                                           // 报错：mj_objectArrayWithKeyValuesArray:]: unrecognized selector sent to class
                                           //NSArray *portals = [WFYHomePortalItem mj_objectArrayWithKeyValuesArray:result];
                                           for (NSInteger i =0; i<result.count; i++) {
                                               WFYHomePortalItem *item = [[WFYHomePortalItem alloc] init];
                                               item = result[i];
                                               [items[[item.Type integerValue]] addObject:item];
                                               /*
                                                item.Name = result[i][@"Name"];
                                                item.Icon = result[i][@"Icon"];
                                                item.URL  = result[i][@"URL"];
                                                [items[[result[i][@"HomePortalType"] integerValue]] addObject:item];
                                                */
                                           }
                                           _groupItems = items;
                                           [_body_0 reloadData];
                                           [_body_1 reloadData];
                                           [_body_2 reloadData];
                                           [self layoutUI];
                                       }];
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
    
    NSMutableArray<WFYHomePortalItem *> *dataSource = _freqUseItems;
    // 取出来源组
    WFYHomePortalItem *sourceItem = dataSource[sourceIndexPath.row];
    // 取出目标组
    //    HomeContr_GroupItem *destinationItem = dataSource[destinationIndexPath.row];
    
    // 从资源数组中移除该数据
    [dataSource removeObject:sourceItem];
    // 将数据插入到资源数组中的目标位置上
    [dataSource insertObject:sourceItem atIndex:destinationIndexPath.row];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.bounces = NO;
    //scrollView.bounces =(scrollView.contentOffset.y <= 0) ? NO : YES;
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
    }else if (collectionView==_freqCollectionView){
        return _freqUseItems.count;
    }
    return 0;
}

/**
 * 返回indexPath对应的cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<WFYHomePortalItem *> *dataSource = nil;
    if (collectionView==_freqCollectionView){
        dataSource = _freqUseItems;
    }else{
        if (collectionView==_body_0) {
            dataSource = _groupItems[0];
        }else if (collectionView==_body_1) {
            dataSource = _groupItems[1];
        }else if (collectionView==_body_2) {
            dataSource = _groupItems[2];
        }
    }
    WFYHomePortalEditCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuserID_PortalEditCell forIndexPath:indexPath];
    cell.portal = dataSource[indexPath.row];
    if (collectionView==_freqCollectionView) {
        cell.cellState = DeleteState;
    }
    else
    {
        cell.cellState = [self isFreqUsePortalItem:dataSource[indexPath.row]]?DisableState:NormalState;
    }
    //如果需要仅限制右上角图标点击有效的话，需要单独添加一个按钮和三张图片，并且给按钮添加点击事件，可参考以下代码
    //[cell.deleteButton addTarget:self action:@selector(deleteCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

//判断是否常用项
- (Boolean)isFreqUsePortalItem:(WFYHomePortalItem *)model
{
    if (_freqUseItems ==nil || _freqUseItems.count == 0) {
        return false;
    }
    for (int i = 0; i < [_freqUseItems count]; i++) {
        WFYHomePortalItem *item = [_freqUseItems objectAtIndex:i];
        if ([model.Name isEqualToString:item.Name]  && [model.Icon isEqualToString:item.Icon]) {
            return true;
        }
    }
    return false;
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
    NSArray<WFYHomePortalItem *> *dataSource = nil;
    if (collectionView==_body_0) {
        dataSource = _groupItems[0];
        [_freqUseItems addObject:dataSource[indexPath.row]];
        _freqCollectionViewRow = _freqUseItems.count-1;
        [_body_0 reloadData];
    }else if (collectionView==_body_1) {
        dataSource = _groupItems[1];
        [_freqUseItems addObject:dataSource[indexPath.row]];
        _freqCollectionViewRow = _freqUseItems.count-1;
        [_body_1 reloadData];
    }else if (collectionView==_body_2) {
        dataSource = _groupItems[2];
        [_freqUseItems addObject:dataSource[indexPath.row]];
        _freqCollectionViewRow = _freqUseItems.count-1;
        [_body_2 reloadData];
    }else{
        WFYHomePortalItem *model= _freqUseItems[indexPath.row];
        [_freqUseItems removeObjectAtIndex:indexPath.row];
        _freqCollectionViewRow = indexPath.row-1;
        if ([model.Type isEqualToString:@"0"]){
            [_body_0 reloadData];
        }else if([model.Type isEqualToString:@"1"]){
            [_body_1 reloadData];
        }else if([model.Type isEqualToString:@"2"]){
            [_body_2 reloadData];
        }
    }
    [self setFreqCollectionView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

/**
 * layout:返回indexPath对应cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_collectionViewCellW, _collectionViewCellW);
}

- (void)editAction:(UIButton *)btn{
    
    [[WFDataBaseManager shareInstance]
     insertHomePortalItemToDB:_freqUseItems
                     complete:^(BOOL result) {
                         if (result) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotiName_didPortalChanged object:nil];
                         }
    }];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
