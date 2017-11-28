//
//  BaseContr.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYGroupMembersContr.h"
#import "ITDRCell.h"
#import "WFYUserInfo.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "StaffInfoContr.h"
#import "StaffModel.h"

@interface GroupMembersContr_Cell : UITableViewCell

@property (weak, nonatomic) ITDRCell *content;

@end

@implementation GroupMembersContr_Cell

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
    ITDRCell *content = [[ITDRCell alloc] init];
    _content = content;
    [self.contentView addSubview:_content];
}

- (void)bindUIValue
{
    _content.line.hidden = YES;
    _content.userInteractionEnabled = NO;
}

- (void)layoutUI
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat contentLeftMargin = w/36;
    CGFloat contentW = w-2*contentLeftMargin, contentH = h*0.9, contentX = contentLeftMargin, contentY = (h-contentH)/2;
    _content.frame = CGRectMake(contentX, contentY, contentW, contentH);
    [_content layoutUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUI];
}

@end

@interface WFYGroupMembersContr ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation WFYGroupMembersContr
{
    CGFloat _cellHeight;
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initIvar];
    [self initUI];
}

- (void)initIvar
{
    _cellHeight = SCREEN_WIDTH*0.18;
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI
{
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
}

- (void)bindUIValue
{
    self.title = [NSString stringWithFormat:@"群组成员(%lu)",
                  (unsigned long)[_GroupMembers count]];
    
    _tableView.backgroundColor = RGB(245, 245, 245);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    _tableView.frame = CGRectMake(0, 0, sw, sh);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    GroupMembersContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[GroupMembersContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    // Configure the cell...
    WFYUserInfo *user = _GroupMembers[indexPath.row];
    if ([user.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.content.mImageView.image = portrait;
    } else {
        [cell.content.mImageView sd_setImageWithURL:[NSURL URLWithString:[user.portraitUri WFYURLString]]
                             placeholderImage:[UIImage imageNamed:@"vips_portraitPlaceholder"]];//@"contact" 注意区分性别
    }
    cell.content.mImageView.layer.masksToBounds = YES;
    cell.content.mImageView.layer.cornerRadius = cell.content.mImageView.bounds.size.height/2.0;//圆形
    cell.content.mImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.content.mTitleLabel.text = user.name;
    cell.content.descLabel.text = @"男，26岁";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_GroupMembers count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WFYUserInfo *user = _GroupMembers[indexPath.row];
    NSLog(@"user: %@",user);
    //需要区分是组织架构成员还是会员 先默认为组织架构成员
    StaffInfoContr *c = [[StaffInfoContr alloc] init];
    StaffModel *staff= [[StaffModel alloc]init];
    staff.usrname=user.userId;
    staff.nickname = user.name;
    staff.avatarUri = user.portraitUri;
//    staff.email = user.email;
    c.staff = staff;
    [self.navigationController pushViewController:c animated:YES];
}

@end
