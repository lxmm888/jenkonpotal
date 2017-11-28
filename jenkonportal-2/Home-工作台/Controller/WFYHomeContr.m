//
//  WFYHomeContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYHomeContr.h"
#import "WFYHomePortalCell.h"
#import "WFYHomePortalItem.h"
#import "WebViewContr.h"
#import "WFYHomePortalContr.h"
#import "WFDataBaseManager.h"
#import "WFHttpTool.h"
#import "AppConf.h"

#define reuserID @"WFYHomePortalCell"

@interface WFYHomeContr ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@end

@implementation WFYHomeContr
{
    CGFloat _collectionViewLeftMargin;
    CGFloat _collectionViewCellW;
    CGFloat _collectionViewVerticalMargin;
    CGFloat _portalViewX;
    CGFloat _portalViewW;
    
    UIScrollView *_scrollView;
    //UIView *_portalBgView;
    UICollectionView *_portalView;
    NSMutableArray<WFYHomePortalItem *> *collectionViewResource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIvar];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self bindUIValue2];
}

- (void)initIvar{
    _collectionViewLeftMargin = SCREEN_WIDTH/20;
    CGFloat collectionViewCellMargin = 1.5*_collectionViewLeftMargin;
    _collectionViewCellW = (SCREEN_WIDTH-2*_collectionViewLeftMargin-3*collectionViewCellMargin)/4;
    _collectionViewVerticalMargin = SCREEN_HEIGHT*0.025;
    
    _portalViewX = 0;
    _portalViewW = SCREEN_WIDTH;
//    _portalViewX =_collectionViewLeftMargin;
//    _portalViewW =SCREEN_WIDTH-2*_collectionViewLeftMargin;
}

- (void)initUI{
    [self creatUI];
    [self bindPortalView];
    [self bindUIValue];
    [self layoutUI];
}

- (void)creatUI{
    _scrollView = [[UIScrollView alloc] init];
    //_portalBgView = [[UIView alloc]init];
    
    [self.view addSubview:_scrollView];
    //[_scrollView addSubview:_portalBgView];
}


- (void)bindUIValue{
    self.title = @"工作台";
    self.view.backgroundColor = RGB(245, 245, 245);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPortalChanged) name:kNotiName_didPortalChanged object:nil];
    //_portalBgView.backgroundColor =[UIColor whiteColor];
}

- (void)layoutUI{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat scrollX = 0, scrollY = 0, scrollW = sw, scrollH = sh-kTabBarH;
    _scrollView.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    
//    CGFloat headerTopMarginToNaviBotm = sh*0.025;
//    CGFloat line = (collectionViewResource.count + 4 -1)/ 4;//总行数
//    CGFloat bodyW = (sw-2*_collectionViewLeftMargin), bodyH = bodyW * 0.21 * line, bodyX = _collectionViewLeftMargin, bodyY_0 = headerTopMarginToNaviBotm;
//    _portalView.frame = CGRectMake(bodyX, bodyY_0, bodyW, bodyH);
}

- (void)bindUIValue2{
    if (collectionViewResource.count<1) {
        [self startLoad];
    }
    
    CGRect contentRect = self.view.frame;
    for (UIView *view in _scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    CGFloat sizeH = contentRect.origin.y+kStatusBarH;
    _scrollView.contentSize = CGSizeMake(0, sizeH);
}

/**
 * 创建UICollectionView视图
 */
- (void)bindPortalView{
    CGRect tempRect = CGRectMake(_portalViewX, 0, _portalViewW, _portalView.collectionViewLayout.collectionViewContentSize.height);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _portalView = [[UICollectionView alloc]initWithFrame:tempRect
                                    collectionViewLayout:flowLayout];
    [_scrollView addSubview:_portalView];
    
    _scrollView.delegate =self;
    _portalView.backgroundColor = [UIColor whiteColor];
    _portalView.dataSource = self;
    _portalView.delegate = self;
    //注册cell
    [_portalView registerClass:[WFYHomePortalCell class] forCellWithReuseIdentifier:reuserID];
}

- (void)setPortalView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_portalView reloadData];
        _portalView.frame = CGRectMake(_portalViewX, 0, _portalViewW, _portalView.collectionViewLayout.collectionViewContentSize.height);
    });
}

- (void)refreshHeaderView {
    NSMutableArray *portalItemList = [[WFDataBaseManager shareInstance] getHomePortalItem];
    collectionViewResource =[[NSMutableArray alloc] initWithArray:portalItemList];
    [self setPortalView];
}

- (void)didPortalChanged {
    [self refreshHeaderView];
}

- (void)startLoad{
    //先查询手机本地，看看有没有存储自定义的portal内容，如果没有则按照用户所属科室默认放置几个按钮
    NSMutableArray *portalItemList = [[WFDataBaseManager shareInstance] getHomePortalItem];
    if ([portalItemList count] > 0) {
        collectionViewResource =
        [[NSMutableArray alloc] initWithArray:portalItemList];
        [self setPortalView];
    }
    else
    {
        [WFHTTPTOOL getHomePortalWithDefaultFlag:@"1"
                                           Block:^(NSArray *result) {
            if ([result count]>0) {
                [[WFDataBaseManager shareInstance]
                 insertHomePortalItemToDB:[result mutableCopy] complete:^(BOOL result) {
                     if (result) {
                         collectionViewResource = [[WFDataBaseManager shareInstance] getHomePortalItem];
                     }
                     else
                     {
                         collectionViewResource = [NSMutableArray new];
                         //添加【更多】按钮
                         WFYHomePortalItem *item = [[WFYHomePortalItem alloc] init];
                         item.Name = @"更多";
                         item.Icon = @"home_cell_more";
                         [collectionViewResource addObject:item];
                     }
                     [self setPortalView];
                 }];
                }
            }
        ];
    }
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.bounces = (scrollView.contentOffset.y <= 0) ? YES : NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout
/**
 * layout:返回indexPath对应cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_collectionViewCellW, _collectionViewCellW);
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _collectionViewVerticalMargin;
}

//cell的最小列间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

//设置每组的cell的边界
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(_collectionViewVerticalMargin, _collectionViewLeftMargin, _collectionViewVerticalMargin, _collectionViewLeftMargin);//top left bottom right
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
    return collectionViewResource.count;
}

/**
 * 返回indexPath对应的cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WFYHomePortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserID forIndexPath:indexPath];
    cell.portal = collectionViewResource[indexPath.row];
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == collectionViewResource.count-1) {
        WFYHomePortalContr *c =[[WFYHomePortalContr alloc]init];
        c.title = collectionViewResource[indexPath.row].Name;
        [self.navigationController pushViewController:c animated:YES];
    }
    else{
        NSString *url = collectionViewResource[indexPath.row].URL;
        //url=@"http://app.xindaowm.com/cn/app/dm/index.html";
        if ([url hasPrefix:@"http"]) { //利用webView加载url即可
            WebViewContr *c = [[WebViewContr alloc] init];
            c.url = url;
            c.title = collectionViewResource[indexPath.row].Name;
            [self.navigationController pushViewController:c animated:YES];
        }else{
            WFYLog(@"不是http协议");
        }
    }
}

@end
