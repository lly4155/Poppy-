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
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};

}

//隐藏显示tabbar
- (void)setTabBarHidden:(BOOL)hidden
{
    UIView *tab = self.tabBarController.view;
    CGRect  tabRect=self.tabBarController.tabBar.frame;
    if ([tab.subviews count] < 2) {
        return;
    }
    
    UIView *view;
    if ([[tab.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        view = [tab.subviews objectAtIndex:1];
    } else {
        view = [tab.subviews objectAtIndex:0];
    }
    
    if (hidden) {
        view.frame = tab.bounds;
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height+self.tabBarController.tabBar.frame.size.height;
    } else {
        view.frame = CGRectMake(tab.bounds.origin.x, tab.bounds.origin.y, tab.bounds.size.width, tab.bounds.size.height);
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height-self.tabBarController.tabBar.frame.size.height;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.tabBarController.tabBar.frame=tabRect;
    }completion:^(BOOL finished) {
        
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self setTabBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self setTabBarHidden:YES];
}

@end
