

//
//  WFYHomePortalContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomePortalContr.h"
#import "AppFontMgr.h"
#import "SVProgressHUD.h"
#import "WebViewContr.h"
#import "WFYHomePortalCell.h"
#import "WFYHomePortalHeader.h"
#import "WFYHomePortalItem.h"
#import "WFHttpTool.h"
#import "AFNetworking.h"
#import "WFYFrequentlyUsedPortalCell.h"
#import "WFDataBaseManager.h"
#import "WFYHomePortalEditContr.h"
#import "AppConf.h"


#define reuserID_UsedCell @"HomeContr_FrequentlyUsedCell"
#define reuserID_BodyCell @"HomeContr_GroupBodyCell"

#define kBodyH(x) (SCREEN_WIDTH-2*SCREEN_WIDTH/20)* 0.21 * ((_groupItems[x].count + 4 -1)/ 4)

@interface WFYHomePortalContr ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@end

@implementation WFYHomePortalContr
{
    CGFloat _collectionViewLeftMargin;
    CGFloat _collectionViewCellW;
    CGFloat _freqCollectionViewCellW;
    
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
    
    [self.view addSubview:_scrollView];
    
    [_scrollView addSubview:_faker];
    
    [_scrollView addSubview:_freqHeader];
    [_scrollView addSubview:_freqCollectionView];
    [_scrollView addSubview:_freqLine];
    [_scrollView addSubview:_freBtn];
    
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
    self.title = @"更多";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //    _scrollView.alwaysBounceVertical = YES;
    
    _scrollView.delegate =self;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _freqHeader.title.text = @"我的常用";
    
    [_freqCollectionView registerClass:[WFYFrequentlyUsedPortalCell class] forCellWithReuseIdentifier:reuserID_UsedCell];
    //    _body_0.layer.masksToBounds = NO;
    _freqCollectionView.backgroundColor = [UIColor clearColor];
    _freqCollectionView.dataSource = self;
    _freqCollectionView.delegate = self;
    
    _freqLine.backgroundColor = RGB(240, 240, 240);
    
    [_freBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_freBtn setTitleColor:RGB(0, 91, 242) forState:UIControlStateNormal];
    _freBtn.titleLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-3];
    [_freBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _header_0.title.text = @"医疗办公";
    
    [_body_0 registerClass:[WFYHomePortalCell class] forCellWithReuseIdentifier:reuserID_BodyCell];
    //    _body_0.layer.masksToBounds = NO;
    _body_0.backgroundColor = [UIColor clearColor];
    _body_0.dataSource = self;
    _body_0.delegate = self;
    
    
    _line_0.backgroundColor = RGB(240, 240, 240);
    
    _header_1.title.text = @"行政办公";
    
    [_body_1 registerClass:[WFYHomePortalCell class] forCellWithReuseIdentifier:reuserID_BodyCell];
    //    _body_1.layer.masksToBounds = NO;
    _body_1.backgroundColor = [UIColor clearColor];
    _body_1.dataSource = self;
    _body_1.delegate = self;
    
    _line_1.backgroundColor = RGB(240, 240, 240);
    
    _header_2.title.text = @"其它系统";
    
    [_body_2 registerClass:[WFYHomePortalCell class] forCellWithReuseIdentifier:reuserID_BodyCell];
    //    _body_2.layer.masksToBounds = NO;
    _body_2.backgroundColor = [UIColor clearColor];
    _body_2.dataSource = self;
    _body_2.delegate = self;
    
    _line_2.backgroundColor = RGB(240, 240, 240);
    
    _faker.image = [UIImage imageNamed:@"faker_workbench"];
    _faker.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPortalChanged) name:kNotiName_didPortalChanged object:nil];
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
    
    CGFloat scrollX = 0, scrollY = 0, scrollW = sw, scrollH = sh-kTabBarH;
    _scrollView.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    
    CGFloat headerTopMarginToNaviBotm = sh*0.025;
    
    CGFloat headerX = 0, freqHeaderY = headerTopMarginToNaviBotm, headerW = sw, headerH = sh*0.03;
    _freqHeader.frame = CGRectMake(headerX, freqHeaderY, headerW, headerH);
    
    CGFloat freqBtnW=50,freqBtnX= sw-_collectionViewLeftMargin-freqBtnW;
    _freBtn.frame = CGRectMake(freqBtnX, freqHeaderY, freqBtnW, headerH);
    
    CGFloat bodyW = (sw-2*_collectionViewLeftMargin), bodyH = bodyW*0.45, bodyX = _collectionViewLeftMargin, freqViewY = freqHeaderY+headerH;
    CGFloat freqViewH = _freqCollectionView.collectionViewLayout.collectionViewContentSize.height;
    _freqCollectionView.frame = CGRectMake(bodyX, freqViewY, bodyW, freqViewH);
    
    CGFloat lineW = sw, lineH = 1, lineX = 0, freqLineY = freqViewY+freqViewH;
    _freqLine.frame = CGRectMake(lineX, freqLineY, lineW, lineH);
    
    CGFloat headerY_0 = freqLineY+lineH+headerTopMarginToNaviBotm;
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
    });
}

- (void)loadFreqUseItem{
    _freqUseItems=[[WFDataBaseManager shareInstance]getHomePortalItem];
    if (_freqUseItems.count >0) {
        [_freqUseItems removeLastObject];
    }
    [self setFreqCollectionView];
}

- (void)didPortalChanged{
    [self loadFreqUseItem];
}

- (void)loadPortalItem{
    NSMutableArray *items = [@[] mutableCopy];
    [items addObject:[@[] mutableCopy]];
    [items addObject:[@[] mutableCopy]];
    [items addObject:[@[] mutableCopy]];
    [WFHTTPTOOL getHomePortalWithDefaultFlag:@"0"
                                       Block:^(NSArray *result) {
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
    /*
     
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
     WFYHomePortalItem *item = [[WFYHomePortalItem alloc] init];
     item.Name = sectionTitles[j];
     item.Icon = sectionImgNames[j];
     [sectionItems addObject:item];
     }
     [items addObject:sectionItems];
     
     }
     _groupItems = items;
     */
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
        WFYFrequentlyUsedPortalCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuserID_UsedCell forIndexPath:indexPath];
        dataSource = _freqUseItems;
        cell.portal =dataSource[indexPath.row];
        return cell;
    }else{
        WFYHomePortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserID_BodyCell forIndexPath:indexPath];
        if (collectionView==_body_0) {
            dataSource = _groupItems[0];
        }else if (collectionView==_body_1) {
            dataSource = _groupItems[1];
        }else if (collectionView==_body_2) {
            dataSource = _groupItems[2];
        }
        cell.portal=dataSource[indexPath.row];
        return cell;
    }
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
    }else if (collectionView==_body_1) {
        dataSource = _groupItems[1];
    }else if (collectionView==_body_2) {
        dataSource = _groupItems[2];
    }else if (collectionView==_freqCollectionView){
        return;
    }
    NSString *url = dataSource[indexPath.row].URL;
    //url=@"http://app.xindaowm.com/cn/app/dm/index.html";
    if ([url hasPrefix:@"http"]) { //利用webView加载url即可
        WebViewContr *c = [[WebViewContr alloc] init];
        c.url = url;
        c.title = dataSource[indexPath.row].Name;
        [self.navigationController pushViewController:c animated:YES];
    }else{
        WFYLog(@"不是http协议");
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

/**
 * layout:返回indexPath对应cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==_freqCollectionView) {
        return CGSizeMake(_freqCollectionViewCellW, _freqCollectionViewCellW);
    }
    else
    {
        return CGSizeMake(_collectionViewCellW, _collectionViewCellW);
    }
}

- (void)editAction:(UIButton *)btn{
    WFYHomePortalEditContr *c = [[WFYHomePortalEditContr alloc]init];
    c.title = self.title;
    [self.navigationController pushViewController:c animated:NO];
}

@end

