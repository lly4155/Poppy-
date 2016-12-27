//
//  LyNewsViewController.m
//  Poppy网易
//
//  Created by LLy on 16/8/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyNewsViewController.h"
#import "MBProgressHUD.h"
#import <WebKit/WebKit.h>
@interface LyNewsViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak)UIProgressView *ProgressView;
@end

@implementation LyNewsViewController

-(instancetype)initWithURLStrs:(NSString *)url{
    if (self = [super init]){
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    // 支持内嵌视频播放，不然网页中的视频无法播放
    config.allowsInlineMediaPlayback = YES;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    // 开始右滑返回手势
    webView.allowsBackForwardNavigationGestures = YES;
    //添加对加载进度的观察者
    UIProgressView *ProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 0)];
    ProgressView.progressTintColor = [UIColor whiteColor];
    ProgressView.trackTintColor = [UIColor clearColor];
    ProgressView.progress = 0.1;//初始值，假象
    [ProgressView setProgressViewStyle:UIProgressViewStyleBar];
    [self.navigationController.navigationBar addSubview:ProgressView];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    self.ProgressView = ProgressView;
    if (_url) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }
    [self.view addSubview:webView];
    self.webView = webView;
}

#pragma mark Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.webView && [keyPath  isEqual: @"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [UIView animateWithDuration:0.5 animations:^{
                self.ProgressView.alpha = 0;
            }completion:^(BOOL finished) {
                [self.ProgressView setProgress:0 animated:NO];
            }];
        }else{
            self.ProgressView.alpha = 1;
            [self.ProgressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark UIWebViewDelegate

// 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// 页面加载完调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 加载HTTPS的链接，需要权限认证时调用
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}


//隐藏tabbar
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //防止没加载完就退出页面，进度条君不会释放问题
    if (self.ProgressView) {
        self.ProgressView.hidden = YES;
        self.ProgressView = nil;
    }
}

-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
