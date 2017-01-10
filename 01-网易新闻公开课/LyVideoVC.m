//
//  LyVideoVC.m
//  Poppy网易
//
//  Created by LLy on 16/7/17.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyVideoVC.h"

@interface LyVideoVC ()

@end

@implementation LyVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.DrawerViewController = (MSDynamicsDrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};

}

-(void)viewDidAppear:(BOOL)animated{
    //侧滑功能打开
    self.DrawerViewController.screenEdgePanCancelsConflictingGestures = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.DrawerViewController.screenEdgePanCancelsConflictingGestures = NO;
}

@end
