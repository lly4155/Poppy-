//
//  LyReplyViewController.m
//  Poppy网易
//
//  Created by LLy on 16/8/7.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyReplyViewController.h"
#import "MBProgressHUD.h"

@interface LyReplyViewController ()<UIWebViewDelegate>
@property (nonatomic,copy) NSString *url;
//@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, weak)UIProgressView *ProgressView;
@property (assign, nonatomic) NSUInteger loadCount;
@end

@implementation LyReplyViewController

- (instancetype)initWithUrl:(NSString *)url{
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加对加载进度的观察者
    UIProgressView *ProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 0)];
    ProgressView.progressTintColor = [UIColor whiteColor];
    ProgressView.trackTintColor = [UIColor clearColor];
    ProgressView.progress = 0.1;//初始值，假象
    [ProgressView setProgressViewStyle:UIProgressViewStyleBar];
    [self.navigationController.navigationBar addSubview:ProgressView];
//    [self.view insertSubview:webView belowSubview:ProgressView];
    self.ProgressView = ProgressView;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    if (_url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [request setValue:@"iPhone AppleWebKit" forHTTPHeaderField:@"User-Agent"];
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [webView loadHTMLString:html baseURL:[NSURL URLWithString:_url]];
        }];
    }
    [self.view addSubview:webView];
    self.webView = webView;
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


#pragma mark - webView代理

// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.ProgressView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.ProgressView setProgress:0 animated:NO];
        }];
    }else {
        self.ProgressView.alpha = 1;
        CGFloat oldP = self.ProgressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.ProgressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount --;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loadCount --;
}


@end
