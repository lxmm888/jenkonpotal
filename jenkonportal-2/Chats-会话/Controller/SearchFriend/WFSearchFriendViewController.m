//
//  WFSearchFriendViewController.m
//  jenkonportal-2
//
//  Created by 赵立 on 2017/8/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFSearchFriendViewController.h"
#import "WFSearchResultTableViewCell.h"
#import "UsrModel.h"
#import "UIImageView+WebCache.h"
#import "DefaultPortraitView.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
#import "WFDataBaseManager.h"
#import "UsrInfoApi.h"
#import "APPWebMgr.h"
#import "SVProgressHUD.h"
#import "StaffModel.h"
#import "XICommonDef.h"
#import "StaffInfoContr.h"
#import "WFAddFriendViewController.h"

@interface WFSearchFriendViewController ()<
UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate,
UISearchControllerDelegate>

@property(strong, nonatomic) NSMutableArray *searchResult;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *searchDisplayController;


@end

@implementation WFSearchFriendViewController
{
    UsrInfoApi *_usrInfoApi;
    APPWebMgr *_webMgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self bindUIValue];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initUI
{
    self.searchBar = [[UISearchBar alloc]init];
    self.searchBar.delegate=self;
    //通过代码关闭输入预测
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
}

- (void)bindUIValue
{
    UIColor *color =self.navigationController.navigationBar.barTintColor;
    [self.navigationController.view setBackgroundColor:color];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.tableFooterView = [UIView new];
    
    self.searchDisplayController =
    [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [self setSearchDisplayController:self.searchDisplayController];
    [self.searchDisplayController setDelegate:self];
    [self.searchDisplayController setSearchResultsDelegate:self];
    [self.searchDisplayController setSearchResultsDataSource:self];
    
    self.navigationItem.title = @"添加好友";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // initial data
    _searchResult = [[NSMutableArray alloc] init];
    
    [self setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
}

//清除多余分割线
- (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


+ (instancetype)searchFriendViewController {
    return [[[self class] alloc] init];
}

- (instancetype)init{
    self=[super init];
    if (self) {
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        self.tableView.backgroundColor= [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        
        _usrInfoApi = [[UsrInfoApi alloc] init];
        _webMgr = [APPWebMgr manager];
        _usrInfoApi.webDelegate = _webMgr;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - searchResultDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchResult.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 80.f;
    }
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reusableCellWithIdentifier = @"WFSearchResultTableViewCell";
    WFSearchResultTableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        cell=[[WFSearchResultTableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:reusableCellWithIdentifier];
        StaffModel *staff=_searchResult[indexPath.row];
        if (staff) {
            cell.lblName.text=staff.nickname;
            if ([staff.avatarUri isEqualToString:@""]) {
                DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                        initWithFrame:CGRectMake(0, 0, 100, 100)];
                [defaultPortrait setColorAndLabel:staff.usrname Nickname:staff.nickname];
                UIImage *portrait = [defaultPortrait imageFromView];
                cell.ivAva.image = portrait;
            }else{
                [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:[staff.avatarUri WFYURLString]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
            }
            
        }
        
    }
    //UIViewContentModeScaleAspectFill 会保证图片比例不变，而且全部显示在ImageView中，这意味着ImageView会有部分空白，不会填充整个区域
    //默认 UIViewContentModeScaleToFill 缩放图片,使图片充满容器，属性会导致图片变形
    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - searchResultDelegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    StaffModel *staff = _searchResult[indexPath.row];
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = staff.usrname;
    userInfo.name = staff.nickname;
    userInfo.portraitUri = staff.avatarUri;
    
    if ([userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        UIAlertView *alert =
        [[UIAlertView alloc]initWithTitle:nil
                                  message:@"你不能添加自己到通讯录"
                                 delegate:nil
                        cancelButtonTitle:@"确定"
                        otherButtonTitles:nil, nil];
        [alert show];
    } else if(staff &&
              tableView == self.searchDisplayController.searchResultsTableView) {
        NSMutableArray *cacheList =[[NSMutableArray alloc]
                                    initWithArray:[[WFDataBaseManager shareInstance]getAllFriends]];
        BOOL isFriend = NO;
        for (UsrModel *tempInfo in cacheList) {
            if ([tempInfo.usrname isEqualToString:staff.usrname] &&
                [tempInfo.status isEqualToString:@"20"]) {
                isFriend = YES;
                break;
            }
        }
        if (isFriend == YES) {
            //已经是好友,进入好友详细信息界面，可以修改备注，发起会话或语音、视频通话
            StaffInfoContr *c = [[StaffInfoContr alloc] init];
            c.staff = staff;
            [self.navigationController pushViewController:c animated:YES];
        }else{
            //还不是好友，进入加好友界面
            WFAddFriendViewController *addViewController = [[WFAddFriendViewController alloc]init];
            addViewController.targetStaffInfo = staff;
            [self.navigationController pushViewController:addViewController animated:YES];
        }
    };
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    [_searchResult removeAllObjects];
    //调用接口“GetUserByName”获取用户信息
    //融云Demo中采取的办法是，当根据录入的内容可能获取到一个人员列表，再分别调用接口获取详细信息
    _usrInfoApi.usrname= searchText;
    if (searchText.length==6) {
        [_usrInfoApi connect:^(ApiRespModel *resp) {
            if (!(resp.resultset[@"success"]) && (resp.resultset[@"error"])) {
                [SVProgressHUD showErrorWithStatus:resp.resultset[@"error"][@"errorMessage"]];
                return;
            } else {
                NSDictionary *usrInfo = resp.resultset;
                StaffModel *staff= [[StaffModel alloc]init];
                staff.uid=[usrInfo[@"UserID"] intValue];
                staff.usrname=usrInfo[@"UserName"];
                staff.nickname=usrInfo[@"NickName"];
                staff.avatarUri=usrInfo[@"Avatar"];
                [_searchResult addObject:staff];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.searchDisplayController
                     .searchResultsTableView reloadData];
                });
            }
        } :^(NSError *error) {
            XILog(@"%@", error.localizedDescription);
        }];
    }
}

//每次searchDisplayController消失的时候都会调用searchDisplayControllerDidEndSearch两次
//正常情况下两次self.searchDisplayController.searchBar的superview都会是tableView
//但是如果你快速点击，那么第二次的superview会是一个UIView，这应该是iOS的系统bug
//参考http://stackoverflow.com/questions/18965713/troubles-with-uisearchbar-uisearchdisplayviewcontroller
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    if (self.tableView != self.searchDisplayController.searchBar.superview) {
        [self.searchDisplayController.searchBar removeFromSuperview];
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
}



@end
