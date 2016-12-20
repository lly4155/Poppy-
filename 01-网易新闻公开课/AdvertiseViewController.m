//
//  AdvertiseViewController.m
//  zhibo
//
//  Created by 周焕强 on 16/5/17.
//  Copyright © 2016年 zhq. All rights reserved.
//

#import "AdvertiseViewController.h"
#import "LyActivityIndicator.h"
#import "SXAdManager.h"

@interface AdvertiseViewController ()<UIWebViewDelegate>

@property (nonatomic, copy) NSString *adUrl;//广告链接
@property (nonatomic, strong) LyActivityIndicator *myIndicator;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation AdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.delegate = self;
    if (!self.adUrl) {
        _adUrl = [SXAdManager getAdUrl];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.adUrl]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    //添加菊花
    self.myIndicator = [[LyActivityIndicator alloc]init];
    [self.view addSubview:self.myIndicator];
}

//webView代理方法
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // 动画开始
    [self.myIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.myIndicator stopAnimating];
}

//懒加载
- (void)setAdUrl:(NSString *)adUrl
{
    _adUrl = adUrl;
}



@end
