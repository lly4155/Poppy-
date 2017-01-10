//
//  LYDrawerViewController.m
//  Poppy网易
//
//  Created by LLy on 2017/1/10.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import "LYDrawerViewController.h"
#import "HyPopMenuView.h"
//分享功能
#import "CommonMarco.h"
#import "XMShareWeiboUtil.h"
#import "XMShareWechatUtil.h"
#import "XMShareQQUtil.h"

@interface LYDrawerViewController ()<HyPopMenuViewDelegate>
@property BOOL flag;//控制分享界面的按钮切换
@end

@implementation LYDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.flag = NO;
    //先随便初试化写死
    self.shareTitle = NSLocalizedString(@"Poppy分享标题", nil);
    
    self.shareText = NSLocalizedString(@"Poppy分享内容", nil);
    
    self.shareUrl = @"https://github.com/lly4155";
}

+(instancetype)sharedDrawer {
    return (LYDrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) closecloseLeftMenuWithDuration:(CGFloat)duration{
    [UIView animateWithDuration:duration animations:^{
        [self setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
    }];
}

//分享弹窗代理
- (void)popMenuView:(HyPopMenuView *)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0://moment
            if (!self.flag) {
                [self shareToWeixinTimeline];
            }else{
                [self FuncFive];
            }
            break;
        case 1://wechat
            if (!self.flag) {
                [self shareToWeixinSession];
            }else{
                [self FuncFive];
            }
            break;
        case 2://QQ
            if (!self.flag) {
                [self shareToQQ];
            }else{
                [self FuncFive];
            }
            break;
        case 3://QQzone
            if (!self.flag) {
                [self shareToQzone];
            }else{
                [self FuncFive];
            }
            break;
        case 4://webo
            if (!self.flag) {
                [self shareToWeibo];
            }else{
                [self FuncFive];
            }
            break;
        case 5://more
            [self FuncFive];
            break;
        default:
            break;
    }
}

#pragma mark - 分享功能
-(void)FuncFive{
    if (self.flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareMenu" object:self userInfo:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moreMenu" object:self userInfo:nil];
    }
    self.flag = !self.flag;
}

- (void)shareToWeixinSession
{
    
    XMShareWechatUtil *util = [XMShareWechatUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    
    [util shareToWeixinSession];
    
}

- (void)shareToWeixinTimeline
{
    
    XMShareWechatUtil *util = [XMShareWechatUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    
    [util shareToWeixinTimeline];
    
}

- (void)shareToQQ
{
    XMShareQQUtil *util = [XMShareQQUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    [util shareToQQ];
}

- (void)shareToQzone
{
    XMShareQQUtil *util = [XMShareQQUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    
    [util shareToQzone];
}

- (void)shareToWeibo
{
    
    XMShareWeiboUtil *util = [XMShareWeiboUtil sharedInstance];
    util.shareTitle = self.shareTitle;
    util.shareText = self.shareText;
    util.shareUrl = self.shareUrl;
    
    [util shareToWeibo];
    
}

@end
