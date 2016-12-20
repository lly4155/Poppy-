//
//  HMDrawerViewController.m
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import "HMDrawerViewController.h"
#import "HMNewsTableViewController.h"
#import "HyPopMenuView.h"
//分享功能
#import "CommonMarco.h"
#import "XMShareWeiboUtil.h"
#import "XMShareWechatUtil.h"
#import "XMShareQQUtil.h"

@interface HMDrawerViewController()<HyPopMenuViewDelegate>
/**
 *  正在显示的控制器
 */
@property (nonatomic, strong) UIViewController *showingVc;
// 左边菜单显示的最大宽度,在AppDelegate中设置
@property (nonatomic, assign) CGFloat leftWidth;
// 主控制器
@property (nonatomic, strong) UIViewController *mainVc;
// 左边菜单控制器
@property (nonatomic, strong) UIViewController *leftMenuVc;
// 遮盖按钮
@property (nonatomic, strong) UIButton *coverBtn;
@property BOOL flag;//控制分享界面的按钮切换
@end

@implementation HMDrawerViewController

//分享弹窗代理
- (void)popMenuView:(HyPopMenuView *)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0://moment
            if (!self.flag) {
                [self shareToWeixinSession];
            }else{
               [self FuncFive];
            }
            break;
        case 1://wechat
            if (!self.flag) {
                [self shareToWeixinTimeline];
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

/**
 *  返回抽屉控制器
 *
 */
+(instancetype)sharedDrawer {
    return (HMDrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}
/**
 *  快速创建一个抽屉控制器
 *
 *  @param mainVc     主控制器
 *  @param leftMenuVc 左边菜单控制器
 *  @param leftWidth  左边菜单控制器最大显示的宽度
 *
 *  @return 抽屉控制器
 */
+(instancetype)drawerWithMainVc:(UIViewController *)mainVc leftMenuVc:(UIViewController *)leftMenuVc leftWidth:(CGFloat)leftWidth {
    // 创建抽屉控制器
    HMDrawerViewController *drawerVc = [[HMDrawerViewController alloc] init];
    // 记录属性
    drawerVc.leftWidth = leftWidth;
    drawerVc.mainVc = mainVc;
    drawerVc.leftMenuVc = leftMenuVc;
    // 将leftMenuVc控制器的view添加到当前控制器view上
    [drawerVc.view addSubview:leftMenuVc.view];
    // 将mainVc控制器的view添加到当前控制器view上
    [drawerVc.view addSubview:mainVc.view];
    
    // 让外界传入的两个控制器成为当前控制器的子控制器
    [drawerVc addChildViewController:leftMenuVc];
    [drawerVc addChildViewController:mainVc];
    // 返回创建好的抽屉控制器
    return drawerVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag = NO;
    // 设置左边菜单控制器默认向左边偏移leftWidth
    self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
    // 给主控制器的左边缘添加阴影效果
    self.mainVc.view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.mainVc.view.layer.shadowOffset = CGSizeMake(-3, -3);
    self.mainVc.view.layer.shadowRadius = 2;
    self.mainVc.view.layer.shadowOpacity = 0.3;
    
    // 为主控制器添加屏幕边缘拖拽手势
//    if([self.mainVc isKindOfClass:[UITabBarController class]]) {
//        NSArray *childViewControllers = self.mainVc.childViewControllers;
//        for (UIViewController *childVc in childViewControllers) {
//            [self addScreenEdgePanGestureRecognizerToView:childVc.view];
//            break;//只给第一个VC右滑手势，一共循环4次nav
//        }
//    } else {
//        [self addScreenEdgePanGestureRecognizerToView:self.mainVc.view];
//    }
    
    //先随便初试化写死
    self.shareTitle = NSLocalizedString(@"Poppy分享标题", nil);
    
    self.shareText = NSLocalizedString(@"Poppy分享内容", nil);
    
    self.shareUrl = @"https://github.com/lly4155";
}

#pragma mark - 手势相关方法
/**
 *  给指定的view的添加边缘拖拽手势
 */
- (UIScreenEdgePanGestureRecognizer *)addScreenEdgePanGestureRecognizerToView:(UIView *)view{
    // 创建屏幕边缘拖拽手势对象
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGestureRecognizer:)];
    // 设置手势触发边缘为左边缘
    pan.edges = UIRectEdgeLeft;
    // 添加手势到指定view
    [view addGestureRecognizer:pan];
    return pan;
}
/**
 *  手势识别回调方法
 */
- (void)edgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)pan {
    // 获得x方向拖动的距离
    CGFloat offsetX = [pan translationInView:pan.view].x;
    // 限制offsetX的最大值为leftWidth
    offsetX = MIN(self.leftWidth, offsetX);
    // 判断手势的状态
    if(pan.state == UIGestureRecognizerStateChanged) {
        // 手势一直处于改变状态
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
        self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth + offsetX, 0);
    } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        // 手势结束或手势被取消了
        // 获得mainVc的x值
        CGFloat mainX = self.mainVc.view.frame.origin.x;
        if (mainX >= self.leftWidth * 0.5) { // 超过屏幕的一半
            [self originalOpenLeftMenuWithDuration:0.15 completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:self userInfo:nil];
        } else { // 没有超过屏幕的一半
            [self closeLeftMenuWithDuration:0.15];
        }
    }
    
}

/**
 *  遮盖按钮拖拽手势回调方法
 */
-(void)panCoverBtn:(UIPanGestureRecognizer *)pan {
    // 获得x方向的拖拽的距离
    CGFloat offsetX = [pan translationInView:pan.view].x;
    // 判断是否大于0
    if(offsetX >= 0)return;
    NSInteger distance =  self.leftWidth - ABS(offsetX);
    if (pan.state == UIGestureRecognizerStateChanged) {
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(MAX(distance, 0), 0);
        self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth + distance, 0);
    } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        CGFloat mainX = self.mainVc.view.frame.origin.x;
        if (mainX >= self.leftWidth * 0.5) { // 超过屏幕的一半
            [self originalOpenLeftMenuWithDuration:0.15 completion:nil];
        } else { // 没有超过屏幕的一半
            [self closeLeftMenuWithDuration:0.15];
        }
    }
}

#pragma mark - 切换到指定的控制器
- (void)switchViewController:(UIViewController *)vc {
    vc.view.frame = self.mainVc.view.bounds;
    vc.view.transform = self.mainVc.view.transform;
    
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    self.showingVc = vc;
    
    [self closeLeftMenuWithDuration:0.25];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        vc.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  回到主页控制器
 */
- (void)backToMainVc {
    self.mainVc.view.transform = CGAffineTransformMakeTranslation(self.mainVc.view.frame.size.width, 0);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.showingVc.view.transform = CGAffineTransformMakeTranslation(self.showingVc.view.frame.size.width, 0);
        self.mainVc.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.showingVc.view removeFromSuperview];
        [self.showingVc removeFromParentViewController];
        self.showingVc = nil;
    }];
}

#pragma mark - 打开和关闭抽屉方法
/**
 *  打开左边菜单原始动画
 */
- (void)originalOpenLeftMenuWithDuration:(CGFloat)duration completion:(void (^)())completion {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(self.leftWidth, 0);
        self.leftMenuVc.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:self userInfo:nil];
        if (!self.coverBtn.superview) {
            // 添加遮盖按钮
            [self.mainVc.view addSubview:self.coverBtn];
        }
        if (completion) {
            completion();
        }
    }];
}

/**
 *  打开左边菜单弹簧动画
 */
- (void)openLeftMenuWithDuration:(CGFloat)duration completion:(void (^)())completion {
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(self.leftWidth, 0);
        self.leftMenuVc.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:self userInfo:nil];
        if (!self.coverBtn.superview) {
            // 添加遮盖按钮
            [self.mainVc.view addSubview:self.coverBtn];
        }
        if (completion) {
            completion();
        }
    }];
}

/**
 *  关闭左边菜单
 */
- (void)closeLeftMenuWithDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.mainVc.view.transform = CGAffineTransformIdentity;
        self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
    } completion:^(BOOL finished) {
        // 移除遮盖按钮
        [self.coverBtn removeFromSuperview];
        self.coverBtn = nil;
    }];
}

#pragma mark - 懒加载遮盖按钮
- (UIButton *)coverBtn {
    if (_coverBtn == nil) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.frame = self.mainVc.view.bounds;
        _coverBtn.backgroundColor = [UIColor clearColor];
        [_coverBtn addTarget:self action:@selector(coverBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        // 添加拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCoverBtn:)];
        [_coverBtn addGestureRecognizer:pan];
    }
    return _coverBtn;
}

- (void)coverBtnClick {
    [self closeLeftMenuWithDuration:0.25];
}
@end
