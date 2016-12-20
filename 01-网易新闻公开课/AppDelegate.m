//
//  AppDelegate.m
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "AppDelegate.h"
#import "HMLeftMenuViewController.h"
#import "HMDrawerViewController.h"
#import "LYTabBarCtl.h"
#import "XHLaunchAd.h"
//#import <Bugrpt/NTESCrashReporter.h>
//#import "CoreJPush.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "CommonMarco.h" //宏定义
#import "ViewController2.h"
#import <IQKeyboardManager.h>

@interface AppDelegate ()<WeiboSDKDelegate, QQApiInterfaceDelegate>
//广告URL和跳转URL
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *action_params;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:APP_KEY_WEIXIN];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:APP_KEY_WEIBO];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self example];
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 *  启动页广告
 */
-(void)example
{
    /**
     *  1.显示启动页广告
     */
    [XHLaunchAd showWithAdFrame:CGRectMake(0, 0,self.window.bounds.size.width, self.window.bounds.size.height-150) setAdImage:^(XHLaunchAd *launchAd) {
        
        //未检测到广告数据,启动页停留时间,默认3,(设置4即表示:启动页显示了4s,还未检测到广告数据,就自动进入window根控制器)
        //launchAd.noDataDuration = 4;
        
        //获取广告数据
        [self requestImageData:^(NSString *imgUrl, NSInteger duration, NSString *openUrl) {
            
            /**
             *  2.设置广告数据
             */
            [launchAd setImageUrl:imgUrl duration:duration skipType:SkipTypeTimeText options:XHWebImageDefault completed:^(UIImage *image, NSURL *url) {
                
                //异步加载图片完成回调(若需根据图片尺寸,刷新广告frame,可在这里操作)
                //launchAd.adFrame = ...;
                
            } click:^{
                
                //广告点击事件
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
                
            }];
            
        }];
        
    } showFinish:^{
        //广告展示完成回调,设置window根控制器
        HMLeftMenuViewController *leftMenuVc = [[HMLeftMenuViewController alloc] init];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LYTabBarCtl *mainVc = sb.instantiateInitialViewController;
//        mainVc.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:238/255.0 alpha:1];
        self.window.rootViewController = [HMDrawerViewController drawerWithMainVc:mainVc leftMenuVc:leftMenuVc leftWidth:self.window.frame.size.width - 70];
    }];
}

/**
 *  模拟:向服务器请求广告数据
 *
 *  @param imageData 回调imageUrl,及停留时间,跳转链接
 */
-(void)requestImageData:(void(^)(NSString *imgUrl,NSInteger duration,NSString *openUrl))imageData{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(imageData)
        {
            [self loadURL];
            imageData(_imgUrl,3,_action_params);
        }
    });
}

-(void) loadURL{
    NSInteger now = [[[NSDate alloc] init] timeIntervalSince1970];
    NSString *path = [NSString stringWithFormat:@"http://g1.163.com/madr?app=7A16FBB6&platform=ios&category=startup&location=1&timestamp=%ld",(long)now];
    NSError *error;
//    NSLog(@"%@",path);
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //解决乱码问题，非UTF8
    NSStringEncoding enc = kCFStringEncodingUTF8;
    
    NSString *strdata = [[NSString alloc]initWithData:response encoding:enc];//在将NSString类型转为NSData
    
    response = [strdata dataUsingEncoding:NSUTF8StringEncoding];//这样解决的乱码问题。
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *adArray = [dict valueForKey:@"ads"];
    //图像URL
    _imgUrl = adArray[0][@"res_url"][0];
    //跳转URL
        _action_params = adArray[0][@"action_params"][@"link_url"];
    if (adArray.count >1) {
        //随机加载广告
        NSInteger randomNum = arc4random() % adArray.count;
        _imgUrl = adArray[randomNum][@"res_url"][0];
        _action_params = adArray[randomNum][@"action_params"][@"link_url"];
    }

//    NSLog(@"%@ , %@",_imgUrl,_action_params);
}


#pragma mark - 处理分享后URL跳转
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url absoluteString] hasPrefix:@"tencent"]) {
        
        //        return [TencentOAuth HandleOpenURL:url];
        return [QQApiInterface handleOpenURL:url delegate:self];
        
    }else if([[url absoluteString] hasPrefix:@"wb"]) {
        
        return [WeiboSDK handleOpenURL:url delegate:self];
        
    }else if([[url absoluteString] hasPrefix:@"wx"]) {
        
        //  处理微信回调需要在具体的 ViewController 中处理。
        ViewController2 *vc = (ViewController2 *)self.window.rootViewController;
        return [WXApi handleOpenURL:url delegate:vc];
        
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] hasPrefix:@"tencent"]) {
        
        return [TencentOAuth HandleOpenURL:url];
        
    }else if([[url absoluteString] hasPrefix:@"wb"]) {
        
        return [WeiboSDK handleOpenURL:url delegate:self];
        
    }else{
        
        ViewController2 *vc = (ViewController2 *)self.window.rootViewController;
        return [WXApi handleOpenURL:url delegate:vc];
        
    }
}
//QQ分享协议
- (void)onResp:(QQBaseResp *)resp
{
    NSString *message;
    if([resp.result integerValue] == 0) {
        message = @"分享成功";
    }else{
        message = @"分享失败";
    }
    showAlert(message);
}
//微博分享协议
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString *message;
    switch (response.statusCode) {
        case WeiboSDKResponseStatusCodeSuccess:
            message = @"分享成功";
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            message = @"取消分享";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            message = @"分享失败";
            break;
        default:
            message = @"分享失败";
            break;
    }
    showAlert(message);
}

@end
