//
//  WFYAnncWebViewContr.m
//  jenkonportal
//
//  Created by 赵立 on 2017/10/13.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import "WFYAnncWebViewContr.h"
#import <WebKit/WebKit.h>
#import "XIProgressView.h"
#import "SVProgressHUD.h"
#import "WFUIBarButtonItem.h"
#import "WFYAnnouncementModel.h"

#import <RongIMKit/RongIMKit.h>

@interface WFYAnncWebViewContr ()<WKNavigationDelegate,WKUIDelegate,UINavigationControllerDelegate>

//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@end

@implementation WFYAnncWebViewContr
{
    WKWebView *_webView;
    XIProgressView *_progressView;
    UIToolbar *_toolBar;
    UIBarButtonItem *_backBtn;
    UIBarButtonItem *_forwardBtn;
    UIBarButtonItem *_closeBtn;
    UIBarButtonItem *_refreshBtn;
    
    NSString *htmlBody;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initUI];
}

- (void)dealloc
{
    [_progressView removeFromSuperview];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)initUI
{
    [self createUI];
    [self bindLeftButton];
    [self bindToolBar];
    [self bindUIValue];
    [self layoutUI];
}

- (void)createUI{
    _progressView = [[XIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.navigationController.view addSubview:_progressView];
    
    _webView = [[WKWebView alloc] init];
    [self.view addSubview:_webView];
}

- (void)bindUIValue
{
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.delegate =self;
    
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.progressTintColor = [UIColor whiteColor];
    
    [self clearWebViewCache];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    //    _webview.allowsBackForwardNavigationGestures = YES;
    _webView.scrollView.bounces = NO;
    
    [WFHTTPTOOL getAnnouncementByID:_announcementId successCompletion:^(WFYAnnouncementModel *model) {
        htmlBody = model.anncContent;
        //加载网页
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
        NSMutableString *htmlString = [NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSRange range = [htmlString rangeOfString:@"<body>"];
        [htmlString insertString:htmlBody atIndex:range.location+range.length];
        [_webView loadHTMLString:htmlString baseURL:url];
        
//        NSString *htmlString =[NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"></head><body>%@</body></html>",htmlBody];
//        [_webView loadHTMLString:htmlString baseURL:nil];
        
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }];
    
    // toolbar 风格
    _toolBar.barTintColor =[UIColor whiteColor];
    _toolBar.tintColor = RGB(0, 90, 119);
}

- (void)layoutUI
{
    CGFloat sw = SCREEN_WIDTH;
    CGFloat sh = SCREEN_HEIGHT;
    
    CGFloat webViewTopMargin = kStatusBarH+kNaviBarH;
    CGFloat webViewH = sh-webViewTopMargin-kToolBarH, webViewY = 0;
    _webView.frame = CGRectMake(0, webViewY, sw, webViewH);
    
    _progressView.frame = (CGRect){0, webViewTopMargin, sw, 3};
    
    CGFloat toolBarY=CGRectGetMaxY(_webView.frame);
    _toolBar.frame = CGRectMake(0, toolBarY, sw, kToolBarH);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 添加关闭按钮
- (void)bindToolBar{
    _toolBar = [[UIToolbar alloc]init];
    [self.view addSubview:_toolBar];
    
    UIImage *backImage= [[UIImage imageNamed:@"navi_back"] imageWithRenderingMode:UIImageRenderingModeAutomatic];//UIImageRenderingModeAlwaysOriginal
    _backBtn = [[UIBarButtonItem alloc]initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    _backBtn.title =@"返回";
    
    UIImage *forwardImage = [[UIImage imageNamed:@"navi_forward"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    _forwardBtn = [[UIBarButtonItem alloc]initWithImage:forwardImage style:UIBarButtonItemStyleDone target:self action:@selector(forwardAction)];
    _forwardBtn.title=@"前进";
    
    UIImage *closeImage = [[UIImage imageNamed:@"navi_close"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    _closeBtn = [[UIBarButtonItem alloc]initWithImage:closeImage style:UIBarButtonItemStyleDone target:self action:@selector(closeAction)];
    _closeBtn.title =@"关闭";
    
    _refreshBtn =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadAction)];
    _refreshBtn.title = @"刷新";
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *itemsArray =@[fixedSpace,_backBtn,flexibleSpace,_forwardBtn,flexibleSpace,_closeBtn,flexibleSpace,_refreshBtn,fixedSpace];
    _toolBar.items=itemsArray;
}

- (void)bindLeftButton
{
    self.navigationItem.leftBarButtonItem = self.backItem;
}

//点击返回的方法
- (void)backAction
{
    //判断是否有上一层H5页面
    if ([_webView canGoBack]) {
        //如果有则返回
        [_webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        [self closeAction];
    }
}

//关闭H5页面，直接回到原生页面
- (void)closeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadAction
{
    [_webView reload];
}

- (void)forwardAction
{
    [_webView goForward];
}

#pragma mark - init 懒加载

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] init];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 6, 87, 23);
        UIImageView *backImg = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"navi_back"]];
        backImg.frame = CGRectMake(-6, 4, 10, 17);
        [backBtn addSubview:backImg];
        UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
        [backText setBackgroundColor:[UIColor clearColor]];
        [backText setTextColor:[UIColor whiteColor]];
        [backText setText:@"返回"];
        [backBtn addSubview:backText];
        [backBtn addTarget:self
                    action:@selector(backAction)
          forControlEvents:UIControlEventTouchUpInside];
        _backItem.customView = backBtn;
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *image = [UIImage imageNamed:@"navi_back"];
//        [btn setImage:image forState:UIControlStateNormal];
//        [btn setTitle:@"返回" forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
//        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        //字体的多少为btn的大小
//        [btn sizeToFit];
//        //左对齐
//        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
//        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
//        btn.frame = CGRectMake(0, 0, 40, 40);
//        _backItem.customView = btn;
    }
    return _backItem;
}

- (UIBarButtonItem *)closeItem
{
//    if (!_closeItem) {
//        _closeItem = [[UIBarButtonItem alloc] init];
//
//        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        closeBtn.frame = CGRectMake(0, 6, 87, 23);
//        UIImageView *closeImg = [[UIImageView alloc]
//                                initWithImage:[UIImage imageNamed:@"navi_close"]];
//        closeImg.frame = CGRectMake(-6, 4, 10, 17);
//        [closeBtn addSubview:closeImg];
//        UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
//        [backText setBackgroundColor:[UIColor clearColor]];
//        [backText setTextColor:[UIColor whiteColor]];
//        [backText setText:@"关闭"];
//        [closeBtn addSubview:backText];
//        [closeBtn addTarget:self
//                    action:@selector(closeNative)
//          forControlEvents:UIControlEventTouchUpInside];
//        _closeItem.customView = closeBtn;
//    }
//    return _closeItem;
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
        _closeItem.tintColor = [UIColor blackColor];
    }
    return _closeItem;
}

//隐藏导航栏 这样做有一个缺点就是在切换tabBar的时候有一个导航栏向上消失的动画
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

#pragma mark - WKWebView

- (void)clearWebViewCache
{
    //    NSSet *dataTypes = [NSSet setWithArray:@[
    //                                             WKWebsiteDataTypeDiskCache,
    //                                             //WKWebsiteDataTypeOfflineWebApplicationCache,
    //                                             WKWebsiteDataTypeMemoryCache,
    //                                            //WKWebsiteDataTypeLocalStorage,
    //                                            //WKWebsiteDataTypeCookies,
    //                                            //WKWebsiteDataTypeSessionStorage,
    //                                            //WKWebsiteDataTypeIndexedDBDatabases,
    //                                            //WKWebsiteDataTypeWebSQLDatabases
    //                                            ]];
    
    NSSet *dataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *from = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataTypes
                                               modifiedSince:from completionHandler:^{
                                               }];
}

#pragma mark - WKWebView Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [_progressView setProgress:_webView.estimatedProgress animated:YES];
    }
}

#pragma mark - WKNavigationDelegate

// 1 在发送请求之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    [_progressView clear];
    // 执行JS脚本
//    NSString *strJs = [NSString stringWithFormat:@"document.getElementsByTagName('body').appendChild(%@);",htmlBody] ;
//    [_webView evaluateJavaScript:strJs completionHandler:^(id _Nullable re, NSError * _Nullable error) {
//
//    }];
}

// 2 初次请求（有可能重定向）
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 3 收到响应后
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 4 提交，并开始连接（有点类似Android的NSURLConnection接入流程）
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 5 下载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_progressView done];
}

// 6 初次请求失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [SVProgressHUD showInfoWithStatus:@"网络超时"];
    XILog(@"页面加载失败");
}

// 发生重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 下载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    XILog(@"加载出错%@", error);
}

// ？ 需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    //用户身份信息
    XILog(@"需要响应身份验证");
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
    }else {
        
        NSURLCredential *newCred = [NSURLCredential credentialWithUser:@""
                                                              password:@""
                                                           persistence:NSURLCredentialPersistenceNone];
        // 为 challenge 的发送方提供 credential
        // [[challenge sender] useCredential:newCred forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCred);
    }
}

// webview加载进程被终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *nativeAlert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [nativeAlert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self.navigationController presentViewController:nativeAlert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *nativeAlert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [nativeAlert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [nativeAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self.navigationController presentViewController:nativeAlert animated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
//    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
//    
//    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

@end
