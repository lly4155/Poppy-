//
//  LyTopicVC.h
//  Poppy网易
//
//  Created by LLy on 16/7/17.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"

@interface LyTopicVC : UIViewController
@property(nonatomic, strong)MSDynamicsDrawerViewController *DrawerViewController;
@property (weak, nonatomic) UITextField *result;
@end
