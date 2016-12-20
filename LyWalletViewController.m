//
//  LyWalletViewController.m
//  Poppy网易
//
//  Created by LLy on 16/10/17.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyWalletViewController.h"
#import "LYtouchID_VC.h"

@interface LyWalletViewController ()

@end

@implementation LyWalletViewController
    
//隐藏tabbar
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.tabBarController.tabBar setHidden:YES];
}
    
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:238/255.0 alpha:1];
    //弹出指纹验证
    LYtouchID_VC *touchID = [[LYtouchID_VC alloc]init];
    [self.navigationController pushViewController:touchID animated:NO];
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
    
@end
