//
//  QQContactViewController.m
//  MTreeViewFramework
//
//  Created by Micker on 16/3/31.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "WFContactSelectedContr.h"
#import <QuartzCore/QuartzCore.h>
#import "XICommonDef.h"
#import "StaffInfoContr.h"
#import "XITagView.h"
#import "APPWebMgr.h"
#import "ZuZhiJiaGouApi.h"
#import "ZuZhiJiaGou_getStaffApi.h"
#import "DepartmentModel.h"
#import "SVProgressHUD.h"
#import "StaffModel.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>
#import "ChatContr.h"
#import "AppSession.h"
#import "WFUIBarButtonItem.h"
#import "UIColor+WFColor.h"
#import "MBProgressHUD.h"
#import "ChatContr.h"
#import "CreateGroupContr.h"
#import "WFHttpTool.h"
#import "DefaultPortraitView.h"

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

static NSString *WFContactSelectedContrNode = @"WFContactSelectedContrNode";

// 模型
@interface CreateGroupChat_CellItem : NSObject

@property (strong, nonatomic) id content;
@property (assign, nonatomic) BOOL selected;

@end

// cell
@interface CreateGroupChat_Cell : UITableViewCell

@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *detailLabel;
@property (weak, nonatomic) UIImageView *userImageView;
@property (weak, nonatomic) UIButton *checkbox;

- (void)setModel:(StaffModel *)user;

@end

@interface WFContactSelectedContr()

@property (nonatomic,strong) WFUIBarButtonItem *rightBtn;

@end

@implementation WFContactSelectedContr
{
    CGFloat _cellHeight;
    // 保存已选群聊成员
    NSMutableArray<CreateGroupChat_CellItem *> *_mems;
    // 已选群聊成员以标签形式显示
    XITagView *_tagView;
    
    APPWebMgr *_webMgr;
    ZuZhiJiaGouApi *_api;
    ZuZhiJiaGou_getStaffApi *_subApi;
    NSInteger _getStaffsFlag;
    
    NSArray<DepartmentModel *> *_depts;// 部门
    
    MBProgressHUD *hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)initIvar
{
    _cellHeight = SCREEN_WIDTH*0.12;
    
    _mems = [@[] mutableCopy];
    
    _webMgr = [APPWebMgr manager];
    
    _api = [[ZuZhiJiaGouApi alloc] init];
    _api.webDelegate = _webMgr;
    
    _subApi = [[ZuZhiJiaGou_getStaffApi alloc] init];
    _subApi.webDelegate = _webMgr;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
    [self ajaxGet];
}

// clicked done
- (void)clickedDone:(id)sender {
    if (self.isAllowsMultipleSelection == NO) {
        //跳转到会话页面
        CreateGroupChat_CellItem *selItem =_mems[0];
        ChatContr *chatController = [[ChatContr alloc] initWithConversationType:ConversationType_PRIVATE targetId: ((StaffModel *)selItem.content).usrname];
        chatController.needPopToRootView = YES;
        chatController.title = ((StaffModel *)selItem.content).nickname;
        [self.navigationController pushViewController:chatController animated:YES];
    }else{
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
        [hud showAnimated:YES];
        
        // get seleted users
        NSMutableArray *seletedUsers = [NSMutableArray new];
        NSMutableArray *seletedUsersId = [NSMutableArray new];
        [_mems enumerateObjectsUsingBlock:^(CreateGroupChat_CellItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [seletedUsers addObject:(StaffModel *)item.content];
            [seletedUsersId addObject:((StaffModel *)item.content).usrname];
        }];
    
        //添加群组成员
        if (_addGroupMembers.count > 0) {
            [WFHTTPTOOL addUsersIntoGroup:_groupId
                                  usersId:seletedUsersId
                                 complete:^(BOOL result) {
                                     if (result == YES) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } else {
                                         [hud setHidden:YES];
                                         UIAlertView *alert = [[UIAlertView alloc]
                                                               initWithTitle:@"添加成员失败"
                                                               message:nil
                                                               delegate:self
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil, nil];
                                         [alert show];
                                         [self.rightBtn buttonIsCanClick:YES
                                                             buttonColor:[UIColor whiteColor]
                                                           barButtonItem:self.rightBtn];
                                     }
                                 }];
        }
        
        //删除群组成员
        if (_delGroupMembers.count > 0) {
            [WFHTTPTOOL kickUsersOutOfGroup:_groupId
                                    usersId:seletedUsersId
                                   complete:^(BOOL result) {
                                       if (result == YES) {
                                           [self.navigationController
                                            popViewControllerAnimated:YES];
                                       } else {
                                           [hud setHidden:YES];
                                           UIAlertView *alert = [[UIAlertView alloc]
                                                                 initWithTitle:@"删除成员失败"
                                                                 message:nil
                                                                 delegate:self
                                                                 cancelButtonTitle:@"确定"
                                                                 otherButtonTitles:nil, nil];
                                           [alert show];
                                           [self.rightBtn buttonIsCanClick:YES
                                                               buttonColor:[UIColor whiteColor]
                                                             barButtonItem:self.rightBtn];
                                       }
                                   }];
        }
        
        //创建群组
        if (self.forCreatingGroup) {
            CreateGroupContr *createGroupVC = [CreateGroupContr createGroupViewController];
            createGroupVC.GroupMemberIdList = seletedUsersId;
            createGroupVC.GroupMemberList = seletedUsers;
            [self.navigationController pushViewController:createGroupVC animated:YES];
            return;
        }
    }
}

/**
 * 创建群聊
 */
- (void)toGroupChat
{

    
}

/**
 * 创建讨论组
 */
- (void)toDiscussionChat
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *curUsrname = [AppSession shareSession].usr.nickname;
    // 组名
    NSMutableString *name = [[NSMutableString alloc] initWithString:@""];
    [name appendString:[NSString stringWithFormat:@"%@、", [AppSession shareSession].usr.nickname]];
    
    for (NSInteger i = 0; i<(_mems.count>2 ? 2 : _mems.count); i++) {
        [name appendString:[NSString stringWithFormat:@"%@、", ((StaffModel *)_mems[i].content).nickname]];
    }
    
    [name deleteCharactersInRange:NSMakeRange(name.length-1, 1)];
    if (_mems.count>2) {
        [name appendString:[NSString stringWithFormat:@"等%ld人", _mems.count+1]];
    }
    
    // debug
    NSMutableArray *usrIdList = [@[] mutableCopy];
    __block BOOL notin = YES;
    [_mems enumerateObjectsUsingBlock:^(CreateGroupChat_CellItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *usrname = ((StaffModel *)obj.content).usrname;
        [usrIdList addObject:usrname];
        if (notin && [curUsrname isEqualToString:usrname]) {
            notin = NO;
        }
    }];
    
    if (notin) {
        [usrIdList addObject:curUsrname];
    }

    [[RCIMClient sharedRCIMClient] createDiscussion:name userIdList:usrIdList success:^(RCDiscussion *discussion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ChatContr *chatController = [[ChatContr alloc] initWithConversationType:ConversationType_DISCUSSION targetId:discussion.discussionId];
            chatController.needPopToRootView = YES;
            chatController.title = discussion.discussionName;
            [self.navigationController pushViewController:chatController animated:YES];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        });
        
    } error:^(RCErrorCode status) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"错误代码：%ld", status]];
    }];
}

- (void)createUI
{
    _tagView = [[XITagView alloc] init];
    [self.view addSubview:_tagView];
}

- (void)bindUIValue
{
    //self.title = @"发起群聊";
    self.title = _titleStr;
    self.treeView.tableFooterView = [[UIView alloc] init];
    self.treeView.allowsMultipleSelection = YES;
    if (_isAllowsMultipleSelection == NO) {
        self.treeView.allowsMultipleSelection = NO;
    }
}

// 1获取所有部门id
- (void)ajaxGet
{
    [SVProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    //入参siteId,siteId值应该从接口Login的回参中获取
    _api.siteId= [AppSession shareSession].usr.siteId;
    [_api connect:^(ApiRespModel *resp) {
        if (resp==NULL) return;
        NSMutableArray *depts = [NSMutableArray arrayWithArray:
                                 ((DepartmentModel *)resp.resultset[_api.departmentKeyName]).children];
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
        
        NSMutableArray *staffs =[NSMutableArray arrayWithArray:
                                 ((NSDictionary *)resp.resultset)[_subApi.staffsKeyName]];
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
        [staffs enumerateObjectsUsingBlock:^(StaffModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //采用下面的方法去删除元素，会出现删除元素后跳跃的情况
//            NSLog(@"遍历%@,下标%ld",obj.usrname,idx);
//            if ([_delGroupMembers count]>0 && ![self isContain:obj.usrname]){
//                NSLog(@"删除%@,下标%ld",obj.usrname,idx);
//                [staffs removeObjectAtIndex:idx];
//            }else{
//                obj.department = department;
//            }
            if ([_delGroupMembers count]>0 && ![self isContain:obj.usrname]){
                [set addIndex:idx];
            }else{
                obj.department = department;
            }
        }];
        [staffs removeObjectsAtIndexes:set];
        //这是第三种循环删除方法，效率较低
//        if ([_delGroupMembers count]>0) {
//            for (StaffModel * staff in staffs.reverseObjectEnumerator) {
//                if (![self isContain:staff.usrname]) {
//                    [staffs removeObject:staff];
//                }
//            }
//        }
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
            
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    });
}

- (void)reloadData
{
    DepartmentModel *vips = [[DepartmentModel alloc] init];
    vips.name = @"我的会员";
    vips.staffs = @[];
    
    NSMutableArray *f = [_depts mutableCopy];
    [f insertObject:vips atIndex:0];
    
    //删除群成员时，如果某一组没有元素则不显示该组
    if ([_delGroupMembers count]>0) {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
        [f enumerateObjectsUsingBlock:^(DepartmentModel *  _Nonnull child, NSUInteger idx, BOOL * _Nonnull stop){
            if ([child.staffs count]==0) {
                [set addIndex:idx];
            }
        }];
        [f removeObjectsAtIndexes:set];
    }
    _depts = f;
    
    
    for (NSInteger i = 0; i<_depts.count; i++) {
        MTreeNode *node = [MTreeNode initWithParent:self.treeView.rootNode expand:NO];
        for (NSInteger j = 0; j<_depts[i].staffs.count; j++) {
            MTreeNode *subnode = [MTreeNode initWithParent:node expand:NO];
            CreateGroupChat_CellItem *item = [[CreateGroupChat_CellItem alloc] init];
            item.content = _depts[i].staffs[j];
            subnode.content = item;
            [node.subNodes addObject:subnode];
        }
        CreateGroupChat_CellItem *item = [[CreateGroupChat_CellItem alloc] init];
        item.content = _depts[i];
        node.content = item;
        [self.treeView.rootNode.subNodes addObject:node];
    }
    [self.treeView reloadData];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    //CGFloat tagLeftMargin = sw/36, tagTopMarginToNaviBotm = tagLeftMargin*0.8, tagTopMargin = kStatusBarH+kNaviBarH+tagTopMarginToNaviBotm;
    CGFloat tagLeftMargin = sw/36, tagTopMarginToNaviBotm = tagLeftMargin*0.8, tagTopMargin = tagTopMarginToNaviBotm;
    CGFloat tagW = sw-2*tagLeftMargin, tagH = 0, tagX = tagLeftMargin, tagY = tagTopMargin;
    _tagView.frame = CGRectMake(tagX, tagY, tagW, tagH);
    [_tagView reloadData];
    
    CGFloat tbTopMarginToTagBotm = tagTopMarginToNaviBotm;
    CGFloat tbW = sw, tbH = sh-(tagY+_tagView.bounds.size.height), tbX = 0, tbY = tagY+_tagView.bounds.size.height+tbTopMarginToTagBotm;
    self.treeView.frame = CGRectMake(tbX, tbY, tbW, tbH);
    [self bindUIValue2];
}

- (void)bindUIValue2
{
    for (UILabel *label in _tagView.subviews) {
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deSelectItem:)];
        [label addGestureRecognizer:tap];
    }
}

- (void) doConfigTreeView {
    self.treeView.rowHeight = 60.0f;
    self.treeView.rootNode = [MTreeNode initWithParent:nil expand:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (BOOL)isContain:(NSString*)userId {
    BOOL contain = NO;
    NSArray *userList;
    if (_addGroupMembers.count > 0) {
        userList = _addGroupMembers;
        for (NSString *memberId in userList) {
            if ([userId isEqualToString:memberId]) {
                contain = YES;
                break;
            }
        }
    }
    if (_delGroupMembers.count > 0) {
        userList = _delGroupMembers;
        for (RCUserInfo *member in userList) {
            if ([userId isEqualToString:member.userId]) {
                contain = YES;
                break;
            }
        }
    }
    return contain;
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
    DepartmentModel *nodeData = ((CreateGroupChat_CellItem *)subNode.content).content;
    
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

//需要设置选中状态，设置哪些行可选，哪些行不可选
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTreeNode *subNode = [self.treeView nodeAtIndexPath:indexPath];
    CreateGroupChat_CellItem *model = subNode.content;
    StaffModel *staff = model.content;
    
    CreateGroupChat_Cell *cell = (CreateGroupChat_Cell *)[tableView dequeueReusableCellWithIdentifier:WFContactSelectedContrNode];
    if (cell==nil) {
        cell = [[CreateGroupChat_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WFContactSelectedContrNode];
    }
    [cell setUserInteractionEnabled:YES];
    //给控件填充数据
    [cell setModel:staff];
//    cell.nameLabel.text = staff.nickname;
//    cell.detailLabel.text = staff.usrname;
//    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:staff.avatarUri] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
    //设置选中状态
    cell.checkbox.enabled =YES;
    cell.checkbox.selected = model.selected;
    if ([_addGroupMembers count]>0 && [self isContain:staff.usrname]==YES) {
        [cell setUserInteractionEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.checkbox.enabled = NO;
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.treeView expandNodeAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MTreeNode *node = [self.treeView nodeAtIndexPath:indexPath];
    CreateGroupChat_CellItem *item = node.content;
    item.selected^=1;//^= 异或赋值,相同取0,不同取1
    if (item.selected==YES) {
        [_mems addObject:item];
    }else {
        [_mems removeObject:item];
    }
    
    if (self.isAllowsMultipleSelection==NO){
        //单聊选择
        if (_mems.count>1) {
          //同时选择了两个人，需要取消第一个成员的选中状态
            CreateGroupChat_CellItem *selItem =_mems[0];
            selItem.selected=NO;
            [_mems removeObject:selItem];
        };
    };
    [self.treeView reloadData];
    
    [self bindUIValue3];
}

- (void)deSelectItem:(UIGestureRecognizer *) recognizer {
    UIView *view = (UILabel *)recognizer.view;
    NSUInteger tag = view.tag;
    CreateGroupChat_CellItem *item = _tagView.tagItems[tag].content;
    item.selected = NO;
    [_mems removeObject:item];
    [self.treeView reloadData];
    
    [self bindUIValue3];
}

-(void) bindUIValue3{
    if (_mems.count==0) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:[NSString stringWithFormat:@"确定(%ld)", _mems.count] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(clickedDone:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = item;
    }
    NSMutableArray *tagItems = [@[] mutableCopy];
    [_mems enumerateObjectsUsingBlock:^(CreateGroupChat_CellItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        XITagModel *tagItem = [[XITagModel alloc] init];
        tagItem.title = ((StaffModel *)item.content).nickname;
        tagItem.content = item;
        [tagItems addObject:tagItem];
    }];
    _tagView.tagItems = tagItems;
    [self layoutUI];
    
}

#pragma mark - Action

- (void) doTipImageView:(UIImageView *)imageView expand:(BOOL) expand {
    [UIView animateWithDuration:0.2f animations:^{
        imageView.transform = (expand) ? CGAffineTransformMakeRotation(DegreesToRadians(90)) : CGAffineTransformIdentity;
    }];
}

- (void)sectionTaped:(UIGestureRecognizer *) recognizer {
    UIView *view = recognizer.view;
    NSUInteger tag = view.tag - 1000;
    UIImageView *tipImageView = [view viewWithTag:10];
    MTreeNode *subNode = [self.treeView nodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self.treeView expandNodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self doTipImageView:tipImageView expand:subNode.expand];
}

@end


@implementation CreateGroupChat_CellItem

@end


@implementation CreateGroupChat_Cell

- (void)setModel:(StaffModel *)user {
    if (user) {
        self.nameLabel.text = user.nickname;
        self.detailLabel.text = user.usrname;
        if ([user.avatarUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                    initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.usrname Nickname:user.nickname];
            UIImage *portrait = [defaultPortrait imageFromView];
            self.userImageView.image = portrait;
        }
        else{
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[user.avatarUri WFYURLString]] placeholderImage:[UIImage imageNamed:@"login_header_avatarPlaceholder"]];
        }
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
        [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.userImageView.layer.masksToBounds = YES;
        self.userImageView.layer.cornerRadius = 20.f;
    } else {
        self.userImageView.layer.masksToBounds = YES;
        self.userImageView.layer.cornerRadius = 5.f;
    }
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
}


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
    UIButton *checkbox = [[UIButton alloc] init];
    
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:detailLabel];
    [self.contentView addSubview:userImageView];
    [self.contentView addSubview:checkbox];
    
    _nameLabel = nameLabel;
    _detailLabel = detailLabel;
    _userImageView = userImageView;
    _checkbox = checkbox;
}

- (void)bindUIValue
{
    _nameLabel.font = [UIFont systemFontOfSize:15];
    
    _detailLabel.font = [UIFont systemFontOfSize:12];
    _detailLabel.textColor = RGB(102, 102, 102);
    
    _checkbox.userInteractionEnabled = NO;
    [_checkbox setImage:[UIImage imageNamed:@"createGroupChat_checkbox_normal"] forState:UIControlStateNormal];
    [_checkbox setImage:[UIImage imageNamed:@"createGroupChat_checkbox_selected"] forState:UIControlStateSelected];
    [_checkbox setImage:[UIImage imageNamed:@"createGroupChat_checkbox_disable"] forState:UIControlStateDisabled];
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
    
    CGFloat checkboxRightMargin = w/24;
    CGFloat checkboxH = h*0.5, checkboxW = checkboxH, checkboxX = w-checkboxRightMargin-checkboxW, checkboxY = (h-checkboxH)/2;
    _checkbox.frame = CGRectMake(checkboxX, checkboxY, checkboxW, checkboxH);
}

@end
