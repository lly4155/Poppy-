//
//  LYTabBarCtl.m
//  Poppy网易
//
//  Created by LLy on 16/7/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LYTabBarCtl.h"
#import "HMNewsTableViewController.h"
#import "SQTabbarControllerAnimatedTransitioning.h"

NSInteger _preIndex = 0;
NSInteger _selectedIndex = 0;

@interface LYTabBarCtl ()<UITabBarControllerDelegate>
@property (nonatomic, assign) BOOL flag;//调节上一次的tabbar选择是哪个
@end

@implementation LYTabBarCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag = YES;
    //UITabBarItem选中时变成红色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} forState:UIControlStateSelected];
    self.tabBar.alpha = 1;
    //设置UINavigationBar的所有字体颜色
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatus) name:@"showStatus" object:nil];
    [self showStatus];
    //添加手势
    UITapGestureRecognizer *doubleClik = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleC:)];
    doubleClik.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleClik];
    
    self.selectedIndex = 0;
}

//重写tabBar的代理方法
- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)vc{
    UIViewController *tbSelectedC = tbc.selectedViewController;
    if ([tbSelectedC isEqual:vc]) {
        return NO;
    }
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    //设置页面跳转时的编号，要添加新的视图时需要设置其tag
    if (!self.flag) {
        _preIndex = _selectedIndex;
    }
    self.flag = NO;
    _selectedIndex = item.tag;
    self.delegate  = self;
}

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return [SQTabbarControllerAnimatedTransitioning new];
}

//双击事件
- (void)doubleC:(UITapGestureRecognizer *)doubleClik{
    if (self.selectedIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doubleClick" object:self userInfo:nil];
    }
    //TODO 剩下的选项双击功能
}

- (void) showStatus{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

-(void) hidenStatus{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:YES];
}



@end
