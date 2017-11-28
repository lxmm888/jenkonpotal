//
//  ContactsContr.m
//  jenkonportal
//
//  Created by 冯文林  on 17/5/9.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "ContactsContr.h"
#import "XIMultiBgColorBtn.h"
#import "XICommonDef.h"
#import "ChatContr.h"
#import "SVProgressHUD.h"
#import "NodeCell.h"
#import "ACCSearchBar.h"
#import "ZuZhiJiaGouContr.h"
#import "VipsContr.h"
#import "GroupChatsContr.h"

@implementation ContactsContr
{
    ACCSearchBar *_searchBar;
    
    NodeCell *_chatGroup;
    NodeCell *_vips;
    NodeCell *_collection;
    
    UITextField *_chat2usr;
    XIMultiBgColorBtn *_chat;
    XIMultiBgColorBtn *_voiceChat;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)toGroupChats
{
    [self.navigationController pushViewController:[[GroupChatsContr alloc] init] animated:YES];
}

- (void)toVips
{
    [self.navigationController pushViewController:[[VipsContr alloc] init] animated:YES];
}

- (void)toCollection
{
    [self.navigationController pushViewController:[[ZuZhiJiaGouContr alloc] init] animated:YES];
}

- (void)initUI
{
    [self createUI];
    [self bindUIValue];
    [self layoutUI];
    [self bindUIValue2];
}

- (void)createUI
{
    _searchBar = [[ACCSearchBar alloc] init];
    _chatGroup = [[NodeCell alloc] init];
    _vips = [[NodeCell alloc] init];
    _collection = [[NodeCell alloc] init];
    
    [self.view addSubview:_searchBar];
    [self.view addSubview:_chatGroup];
    [self.view addSubview:_vips];
    [self.view addSubview:_collection];
    
    _chat2usr = [[UITextField alloc] init];
    _chat = [[XIMultiBgColorBtn alloc] init];
    _voiceChat = [[XIMultiBgColorBtn alloc] init];
    
    [self.view addSubview:_chat2usr];
    [self.view addSubview:_chat];
    [self.view addSubview:_voiceChat];
}

- (void)bindUIValue
{
    self.title = @"通讯录";
    self.view.backgroundColor = RGB(245, 245, 245);
    
    _searchBar.backgroundColor = RGB(220, 220, 220);
    _searchBar.textField.font = [UIFont systemFontOfSize:14];
    _searchBar.textField.placeholder = @"搜一搜";
    [_searchBar setPlaceholderTextColor:RGB(172, 172, 172)];

    UIColor *cellHltColor = RGB(250, 250, 250);
    _chatGroup.backgroundColor = [UIColor whiteColor];
    _chatGroup.mTitleLabel.text = @"群聊";
    _chatGroup.mImageView.image = [UIImage imageNamed:@"contacts_chatGroup"];
    [_chatGroup setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    [_chatGroup addTarget:self action:@selector(toGroupChats) forControlEvents:UIControlEventTouchUpInside];
    
    _vips.backgroundColor = [UIColor whiteColor];
    _vips.mTitleLabel.text = @"我的会员";
    _vips.mImageView.image = [UIImage imageNamed:@"contacts_vips"];
    [_vips setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    [_vips addTarget:self action:@selector(toVips) forControlEvents:UIControlEventTouchUpInside];
    
    _collection.backgroundColor = [UIColor whiteColor];
    _collection.mTitleLabel.text = @"组织架构";
    _collection.mImageView.image = [UIImage imageNamed:@"contacts_collection"];
    [_collection setBackgroundColorForStateNormal:[UIColor whiteColor] hightlighted:cellHltColor];
    [_collection addTarget:self action:@selector(toCollection) forControlEvents:UIControlEventTouchUpInside];
    
    _chat2usr.hidden = YES;
    _chat2usr.placeholder = @"对方ID";
    _chat2usr.layer.borderColor = rgba(227, 227, 227, 1).CGColor;
    _chat2usr.layer.borderWidth = 1;
    
    _chat.hidden = YES;
    [_chat setBackgroundColorForStateNormal:rgba(75, 125, 228, 1) hightlighted:rgba(62, 104, 189, 1)];
    [_chat setTitle:@"发起会话" forState:UIControlStateNormal];
    [_chat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chat addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
    
    _voiceChat.hidden = YES;
    [_voiceChat setBackgroundColorForStateNormal:rgba(75, 125, 228, 1) hightlighted:rgba(62, 104, 189, 1)];
    [_voiceChat setTitle:@"发起群聊" forState:UIControlStateNormal];
    [_voiceChat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_voiceChat addTarget:self action:@selector(toDiscussionChat) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat searchBarTopMarginToNaviBarBotm = kStatusBarH*0.4;
    CGFloat searchBarW = sw*0.9, searchBarH = searchBarW*0.12, searchBarX = (sw-searchBarW)/2, searchBarY = searchBarTopMarginToNaviBarBotm;//kStatusBarH+kNaviBarH+searchBarTopMarginToNaviBarBotm;
    _searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarW, searchBarH);
    [_searchBar layoutUI];
    
    CGFloat nodeCellW = sw, nodeCellH = sw*0.15, nodeCellX = 0;
    CGFloat nodeCellMargin = nodeCellH/7;
    
    CGFloat chatGroupY = searchBarY+searchBarH+searchBarTopMarginToNaviBarBotm;
    _chatGroup.frame = CGRectMake(nodeCellX, chatGroupY, nodeCellW, nodeCellH);
    
    CGFloat vipsY = chatGroupY+nodeCellH+nodeCellMargin;
    _vips.frame = CGRectMake(nodeCellX, vipsY, nodeCellW, nodeCellH);
    
    CGFloat collectionY = vipsY+nodeCellH+nodeCellMargin;
    _collection.frame = CGRectMake(nodeCellX, collectionY, nodeCellW, nodeCellH);
    
    
    CGFloat usrTopMargin = sh*0.45;
    CGFloat chatLeftMarginToUsrRight = sw/24;
    
    CGFloat usrW = sw*0.3, usrH = usrW*0.3;
    CGFloat chatW = sw/4, chatH = usrH;
    
    CGFloat usrX = (sw-usrW-chatW-chatLeftMarginToUsrRight)/2, usrY = usrTopMargin;
    CGFloat chatX = usrX+usrW+chatLeftMarginToUsrRight, chatY = usrY;
    
    CGFloat voiceChatY = chatY+chatH+20;
    
    _chat2usr.frame = CGRectMake(usrX, usrY, usrW, usrH);
    _chat.frame = CGRectMake(chatX, chatY, chatW, chatH);
    _voiceChat.frame = CGRectMake(chatX, voiceChatY, chatW, chatH);
}

- (void)bindUIValue2
{
    _searchBar.leftItemStyle = ACCSearchBarLeftItemStyleSearchGray;
    _searchBar.layer.cornerRadius = _searchBar.bounds.size.height/2;
    
    _chat2usr.layer.cornerRadius = _chat2usr.bounds.size.height/10;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
