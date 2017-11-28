//
//  testViewController.m
//  jenkonportal
//
//  Created by Xuan on 2017/11/24.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "testViewController.h"

@interface testViewController ()

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick)];
//    self.navigationController.navigationItem = rightBarButton;
    self.navigationItem.rightBarButtonItem = rightBarButton;
   
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    //设置需要将哪些类型的会话在会话列表中聚合显示
    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                          @(ConversationType_GROUP)]];
}

- (void)rightBtnClick
{
    RCConversationViewController *vc = [[RCConversationViewController alloc] init];
    vc.conversationType = ConversationType_PRIVATE;
    vc.targetId = @"2";
    vc.title = @"title";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    RCConversationViewController *vc = [[RCConversationViewController alloc] init];
    vc.conversationType = model.conversationType;
    vc.targetId = model.targetId;
    vc.title = @"title";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
