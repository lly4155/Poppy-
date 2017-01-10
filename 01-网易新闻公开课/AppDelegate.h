//
//  AppDelegate.h
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@end

