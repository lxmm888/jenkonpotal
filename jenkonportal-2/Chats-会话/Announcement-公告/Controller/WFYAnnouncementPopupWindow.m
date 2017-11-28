//
//  WFYAnnouncementPopupWindow.m
//  jenkonportal
//
//  Created by 赵立 on 2017/9/30.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnnouncementPopupWindow.h"
#import "WFYAnnouncementModel.h"
#import "WFYCollectionModel.h"

@interface WFYAnncContr_Cell : UITableViewCell

@property (strong,nonatomic) UIView *line;
@property (strong,nonatomic) UILabel *contentLabel;

@end

@implementation WFYAnncContr_Cell

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
    self.line = [[UIView alloc]init];
    self.contentLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.line];
}

- (void)bindUIValue
{
    self.line.backgroundColor = rgba(228, 235, 235, 0.6);
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.font = [UIFont systemFontOfSize:[AppFontMgr standardFontSize]-1];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat contentLeftMargin = w/36;
    CGFloat contentW = w-2*contentLeftMargin, contentH = h*0.9, contentX = contentLeftMargin, contentY = (h-contentH)/2;
    self.contentLabel.frame = CGRectMake(contentX, contentY, contentW, contentH);
    

    CGFloat lineH = 0.5;
    self.line.frame = CGRectMake(0, 0, w, lineH);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

@end

@interface WFYAnnouncementPopupWindow ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WFYAnnouncementPopupWindow
{
    CGFloat _cellHeight;
    NSArray *_actionArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIvar];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)initIvar
{
    _cellHeight = 50;
    _actionArr = @[@"转发",@"收藏",@"删除"];
}

- (void)initUI{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI{
    self.dismissBtn = [[UIButton alloc]init];
    self.centerView = [[UIView alloc]init];
    self.tableView = [[UITableView alloc]init];
    
    [self.view addSubview:self.dismissBtn];
    [self.view addSubview:self.centerView];
    [self.centerView addSubview:self.tableView];
}

- (void)bindUIValue{
    //千万别设置view的alpha 设置alpha 会导致view下的所有子视图都变透明
    self.view.backgroundColor = [UIColor clearColor];
    self.centerView.backgroundColor = RGB(255, 255, 255);
    self.dismissBtn.backgroundColor = [UIColor blackColor];
    self.dismissBtn.alpha = 0.5f;//设置按钮透明度
    [self.dismissBtn addTarget:self action:@selector(dismissBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.bounces=NO;
    self.tableView.backgroundColor = RGB(255, 255, 255);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    /** 去除tableview 右侧滚动条 */
    self.tableView.showsVerticalScrollIndicator = NO;
    /** 去掉分割线 */
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)layoutUI{
    CGFloat space = SCREEN_WIDTH * 0.1;
    CGFloat centerViewW = SCREEN_WIDTH - 2 * space;
    CGFloat centerViewH = _cellHeight * _actionArr.count;
    self.centerView.frame = CGRectMake(space, (SCREEN_HEIGHT - centerViewH) * 0.5, centerViewW, centerViewH);
    self.dismissBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.tableView.frame = CGRectMake(0, 0, centerViewW, centerViewH);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- 按钮点击事件
//关闭弹窗按钮
- (void) dismissBtn:(UIButton *)btn{
     [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    WFYAnncContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[WFYAnncContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    cell.contentLabel.text = _actionArr[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actionArr.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.centerView.hidden = YES;
    //采用UIAlertController来弹出对话框，会出现灰色背景，颜色与目前的灰色背景不一致
    //解决办法，在当前页面下隐藏tableview然后确认对话框
    if (indexPath.row==1){  //收藏 收藏的内容应该存放在服务器，用户换一部手机，收藏的内容应该还可以访问
        WFYAnnouncementModel *anncModel = [[WFDataBaseManager shareInstance]getAnnouncementByID:_announcementId];
        WFYCollectionModel *cltModel = [[WFYCollectionModel alloc]init];
        cltModel.collectionSourceId = anncModel.announcementId;
        cltModel.collectionSourceName = @"公告";
        cltModel.collectionSourceType = @"1";
        //发送网络请求，请求服务器接口DoCollect
        [WFHTTPTOOL doCollectWithCollection:cltModel
                                   complete:^(NSString * collectionId) {
                                       if (collectionId) {
                                           //调用接口根据id获取单个收藏，返回收藏的详细信息
                                           [WFHTTPTOOL getCollectionByID:collectionId
                                                       successCompletion:^(WFYCollectionModel *collection) {
                                                           [[WFDataBaseManager shareInstance]insertCollectionToDB:collection];
                                                       }];
                                           //添加动画，提示“已收藏”
                                           WFYLog(@"未完待续，添加动画，提示“已收藏”");
                                       }else{
                                           self.navigationItem.rightBarButtonItem.enabled =YES;
                                           [self Alert:@"添加收藏失败，请检查你的网络设置。"];
                                       }
                                   }];
    }
    else if (indexPath.row==2) {//删除
        UIAlertController *alertContr=[UIAlertController alertControllerWithTitle:@"是否删除该条消息？"
                                                                          message:nil
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 nil;
                                                             }];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 if (self.delegate &&
                                                                     [self.delegate respondsToSelector:@selector(deleteAnncMsgClicked:)]) {
                                                                     [self.delegate deleteAnncMsgClicked:_indexPath];
                                                                 }
                                                             }];
        [alertContr addAction:cancelAction];
        [alertContr addAction:deleteAction];
        [self presentViewController:alertContr animated:YES completion:nil];
//        UIActionSheet *actionSheet =
//        [[UIActionSheet alloc] initWithTitle:@"是否删除该条消息？"
//                                    delegate:self
//                           cancelButtonTitle:@"取消"
//                      destructiveButtonTitle:@"确定"
//                           otherButtonTitles:nil];
//
//        [actionSheet showInView:self.view];
//        actionSheet.tag = 100;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)Alert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
