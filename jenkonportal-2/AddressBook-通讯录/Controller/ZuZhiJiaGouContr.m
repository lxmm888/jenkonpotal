//
//  QQContactViewController.m
//  MTreeViewFramework
//
//  Created by Micker on 16/3/31.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "ZuZhiJiaGouContr.h"
#import <QuartzCore/QuartzCore.h>
#import "XICommonDef.h"
#import "StaffInfoContr.h"
#import "APPWebMgr.h"
#import "ZuZhiJiaGouApi.h"
#import "DepartmentModel.h"
#import "ZuZhiJiaGou_getStaffApi.h"
#import "SVProgressHUD.h"
#import "StaffModel.h"
#import "UIImageView+WebCache.h"
#import "AppSession.h"

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

static NSString *ZuZhiJiaGouContrNode = @"ZuZhiJiaGouContrNode";

@interface ZuZhiJiaGouContr_Cell : UITableViewCell

@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *detailLabel;
@property (weak, nonatomic) UIImageView *userImageView;

@end

@implementation ZuZhiJiaGouContr_Cell

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
    UILabel *nameLabel = [[UILabel alloc] init];
    UILabel *detailLabel = [[UILabel alloc] init];
    UIImageView *userImageView = [[UIImageView alloc] init];
    
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:detailLabel];
    [self.contentView addSubview:userImageView];
    
    _nameLabel = nameLabel;
    _detailLabel = detailLabel;
    _userImageView = userImageView;
}

- (void)bindUIValue
{
    _nameLabel.font = [UIFont systemFontOfSize:15];
    
    _detailLabel.font = [UIFont systemFontOfSize:12];
    _detailLabel.textColor = RGB(102, 102, 102);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutUI];
    [self bindUIValue2];
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat imageViewLeftMargin = w/12;
    CGFloat imageViewH = h*0.8, imageViewW = imageViewH, imageViewX = imageViewLeftMargin, imageViewY = (h-imageViewH)/2;
    _userImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    
    CGFloat nameTopMarginToImageViewTop = imageViewH/12;
    CGFloat nameLeftMarginToImageViewRight = imageViewW/5;
    CGFloat ratio = 0.65;
    CGFloat nameW = w-2*imageViewLeftMargin-imageViewW-nameLeftMarginToImageViewRight, nameH = (imageViewH-2*nameTopMarginToImageViewTop)*ratio, nameX = imageViewX+imageViewW+nameLeftMarginToImageViewRight, nameY = imageViewY+nameTopMarginToImageViewTop;
    _nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
    
    CGFloat descW = nameW, descH = (imageViewH-2*nameTopMarginToImageViewTop)*(1-ratio), descX = nameX, descY = nameY+nameH;
    _detailLabel.frame = CGRectMake(descX, descY, descW, descH);
}

- (void)bindUIValue2
{
//    _userImageView.layer.cornerRadius = _userImageView.bounds.size.height/2;
    _userImageView.layer.masksToBounds = YES;
}

@end


@implementation ZuZhiJiaGouContr
{
    CGFloat _cellHeight;
    APPWebMgr *_webMgr;
    ZuZhiJiaGouApi *_api;
    ZuZhiJiaGou_getStaffApi *_subApi;
    NSInteger _getStaffsFlag;
    
    NSArray<DepartmentModel *> *_depts;// 部门
    
    BOOL _focusFlag;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
    [self bindUIValue];
    [self ajaxGet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _focusFlag = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _focusFlag = NO;
    [SVProgressHUD dismiss];
    [_webMgr.operationQueue cancelAllOperations];
}

- (void)initIvar
{
    _cellHeight = SCREEN_WIDTH*0.12;
    _webMgr = [APPWebMgr manager];
    
    _api = [[ZuZhiJiaGouApi alloc] init];
    _api.webDelegate = _webMgr;
    
    _subApi = [[ZuZhiJiaGou_getStaffApi alloc] init];
    _subApi.webDelegate = _webMgr;
}

- (void)bindUIValue
{
    self.title = @"组织架构";
    self.treeView.tableFooterView = [[UIView alloc] init];
}

// 1获取所有部门id
- (void)ajaxGet
{
    [SVProgressHUD showWithStatus:@"正在获取..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_focusFlag) {
            [SVProgressHUD dismiss];
        }
    });
    
    //入参siteId,siteId值应该从接口Login的回参中获取
    _api.siteId= [AppSession shareSession].usr.siteId;
    [_api connect:^(ApiRespModel *resp) {
        if (resp==NULL) return;
        
        NSArray *depts = ((DepartmentModel *)resp.resultset[_api.departmentKeyName]).children;
        _depts = depts;
        _getStaffsFlag = depts.count;
        
        [depts enumerateObjectsUsingBlock:^(DepartmentModel *  _Nonnull child, NSUInteger idx, BOOL * _Nonnull stop) {
            [self ajaxGet2:child];
        }];
        
    } :^(NSError *error) {
        [self ajaxGetStaff:NO];
        XILog(@"%@", error.localizedDescription);
    }];
}

// 2获取某部门的所有职员
- (void)ajaxGet2:(DepartmentModel *)department
{
    _subApi.departmentId = department.uid;
    [_subApi connect:^(ApiRespModel *resp) {
        if (resp==NULL) return;
        NSArray *staffs = ((NSDictionary *)resp.resultset)[_subApi.staffsKeyName];
        [staffs enumerateObjectsUsingBlock:^(StaffModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.department = department;
        }];
        
        department.staffs = staffs;
        [self ajaxGetStaff:YES];
        
    } :^(NSError *error) {
        [self ajaxGetStaff:NO];
        XILog(@"%@", error.localizedDescription);
    }];
}

- (void)ajaxGetStaff:(BOOL)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (success) {
            _getStaffsFlag--;
        }else {
            _getStaffsFlag = -1;
        }
        
        if (_getStaffsFlag==0) {// 加载成功
            
            // reload data
            [self reloadData];
            [SVProgressHUD dismiss];
            
        }else if (_getStaffsFlag==-1) {// 加载失败
            
            if (_focusFlag) {
                [SVProgressHUD showErrorWithStatus:@"加载失败"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }

    });
}

- (void)doConfigTreeView {
    self.treeView.rowHeight = 60.0f;
    self.treeView.rootNode = [MTreeNode initWithParent:nil expand:NO];
}

- (void)reloadData
{
    for (NSInteger i = 0; i<_depts.count; i++) {
        MTreeNode *node = [MTreeNode initWithParent:self.treeView.rootNode expand:NO];
        for (NSInteger j = 0; j<_depts[i].staffs.count; j++) {
            MTreeNode *subnode = [MTreeNode initWithParent:node expand:NO];
            subnode.content = _depts[i].staffs[j];
            [node.subNodes addObject:subnode];
        }
        node.content = _depts[i];
        [self.treeView.rootNode.subNodes addObject:node];
    }
    [self.treeView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

// 伪分组
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 1 == section ? 20 : 0.1f ;
//}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 1 == section ? 20 : 0.1f)];
//    footerView.alpha = 0;
//    return footerView;
//}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MTreeNode *subNode = [[self.treeView.rootNode subNodes] objectAtIndex:section];
    DepartmentModel *nodeData = subNode.content;
    
    CGFloat h = 50;
    CGFloat w = tableView.bounds.size.width;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), h)];
    sectionView.tag = 1000 + section;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTaped:)];
    [sectionView addGestureRecognizer:recognizer];
    sectionView.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.5f;
    [sectionView addSubview:line];
    
    // arrow
    CGFloat arrowLeftMargin = w/24;
    CGFloat arrowH = h*0.2, arrowW = arrowH*0.8, arrowX = arrowLeftMargin, arrowY = (h-arrowH)/2;
    UIImageView *tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowX, arrowY, arrowW, arrowH)];
    tipImageView.image = [UIImage imageNamed:@"common_rightItem"];
    tipImageView.tag = 10;
    [sectionView addSubview:tipImageView];
    [self doTipImageView:tipImageView expand:subNode.expand];
    
    // title
    CGFloat titleLeftMarginToArrowRight = arrowLeftMargin;
    CGFloat titleW = w-2*arrowLeftMargin-titleLeftMarginToArrowRight-arrowW, titleH = h*0.6, titleX = arrowX+arrowW+titleLeftMarginToArrowRight, titleY = (h-titleH)/2;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
    label.font = [UIFont systemFontOfSize:15];
    label.tag = 20;
    
    NSString *title = nodeData.name;
    NSString *num = [NSString stringWithFormat:@"  (%ld)", nodeData.staffs.count];
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title, num]];
    [titleText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(title.length, num.length)];
    [titleText addAttributes:@{NSForegroundColorAttributeName:RGB(102, 102, 102)} range:NSMakeRange(title.length, num.length)];
    label.attributedText = titleText;
    [sectionView addSubview:label];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTreeNode *subNode = [self.treeView nodeAtIndexPath:indexPath];
    StaffModel *nodeData = subNode.content;
    ZuZhiJiaGouContr_Cell *cell = (ZuZhiJiaGouContr_Cell *)[tableView dequeueReusableCellWithIdentifier:ZuZhiJiaGouContrNode];
    if (cell==nil) {
        cell = [[ZuZhiJiaGouContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZuZhiJiaGouContrNode];
    }
    cell.nameLabel.text = nodeData.nickname;
    cell.detailLabel.text = nodeData.usrname;
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:[nodeData.avatarUri WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.treeView expandNodeAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MTreeNode *node = [self.treeView nodeAtIndexPath:indexPath];
    StaffInfoContr *c = [[StaffInfoContr alloc] init];
    c.staff = [self.treeView nodeAtIndexPath:indexPath].content;
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - Action

- (void)doTipImageView:(UIImageView *)imageView expand:(BOOL) expand {
    [UIView animateWithDuration:0.2f animations:^{
        imageView.transform = (expand) ? CGAffineTransformMakeRotation(DegreesToRadians(90)) : CGAffineTransformIdentity;
    }];
}

- (void)sectionTaped:(UIGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    NSUInteger tag = view.tag - 1000;
    UIImageView *tipImageView = [view viewWithTag:10];
    MTreeNode *subNode = [self.treeView nodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self.treeView expandNodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self doTipImageView:tipImageView expand:subNode.expand];
}

@end
