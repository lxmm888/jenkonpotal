//
//  VipsContr.m
//  jenkonportal-2
//
//  Created by 冯文林  on 2017/5/22.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "VipsContr.h"
#import "ITDRCell.h"

@interface VipsContr_Cell : UITableViewCell

@property (weak, nonatomic) ITDRCell *content;

@end

@implementation VipsContr_Cell

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
    _content.rightItem.hidden = YES;
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

@interface VipsContr ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation VipsContr
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
    self.title = @"我的会员";
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"reuseID";
    VipsContr_Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[VipsContr_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    cell.content.mImageView.image = [UIImage imageNamed:@"vips_portraitPlaceholder"];
    cell.content.mTitleLabel.text = @"王飞";
    cell.content.descLabel.text = @"男，26岁";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
