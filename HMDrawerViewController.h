//
//  HMDrawerViewController.h
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMDrawerViewController : UIViewController
//  分享标题
@property (nonatomic, strong) NSString *shareTitle;

//  分享文本
@property (nonatomic, strong) NSString *shareText;

//  分享链接
@property (nonatomic, strong) NSString *shareUrl;

/**
 *  快速创建一个抽屉控制器
 *
 *  @param mainVc     主控制器
 *  @param leftMenuVc 左边菜单控制器
 *  @param leftWidth  左边菜单控制器最大显示的宽度
 *
 *  @return 抽屉控制器
 */
+(instancetype)drawerWithMainVc:(UIViewController *)mainVc leftMenuVc:(UIViewController *)leftMenuVc leftWidth:(CGFloat)leftWidth;
/**
 *  返回抽屉控制器
 */
+ (instancetype)sharedDrawer;
/**
 *  打开左边菜单
 */
- (void)openLeftMenuWithDuration:(CGFloat)duration completion:(void (^)())completion;
/**
 *  关闭左边菜单
 */
- (void)closeLeftMenuWithDuration:(CGFloat)duration;

/**
 *  切换到指定的控制器
 */
- (void)switchViewController:(UIViewController *)vc;
/**
 *  回到主页
 */
- (void)backToMainVc;

//给予左滑手势功能,为了埋一个坑，解决collectionView手势冲突问题
- (UIScreenEdgePanGestureRecognizer *)addScreenEdgePanGestureRecognizerToView:(UIView *)view;

@end
