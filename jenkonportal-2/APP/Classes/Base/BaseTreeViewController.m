//
//  BaseTreeViewController.m
//  MTreeViewFramework
//
//  Created by Micker on 16/3/31.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "BaseTreeViewController.h"
#import "XICommonDef.h"

static NSString *NODE_CELL_ID = @"NODE_CELL_ID";

@interface BaseTreeViewController () 
@end

@implementation BaseTreeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat treeViewTopMargin = 0;//kStatusBarH+kNaviBarH;
    // init treeView
    self.treeView = [[MTreeView alloc] initWithFrame:CGRectMake(0,treeViewTopMargin, sw, sh-treeViewTopMargin)];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.treeViewDelegate = self;
    self.treeView.bounces = NO;
    [self.view addSubview:self.treeView];
    
    self.view.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1];
    self.treeView.backgroundColor = [UIColor clearColor];
    [self doConfigTreeView];
    [self.treeView reloadData];
}

- (void) doConfigTreeView {
    
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_treeView numberOfSectionsInTreeView:_treeView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_treeView treeView:_treeView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_treeView expandNodeAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MTreeView delegate

- (void) treeView:(MTreeView *)treeView willexpandNodeAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) treeView:(MTreeView *)treeView didexpandNodeAtIndexPath:(NSIndexPath *)indexPath {
}

@end
