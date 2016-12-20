//
//  LYtouchID_VC.m
//  Poppy网易
//
//  Created by LLy on 16/9/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LYtouchID_VC.h"
#import "HMLeftMenuViewController.h"
#import "HMDrawerViewController.h"
#import "LYTabBarCtl.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface LYtouchID_VC ()
@property(nonatomic , weak)UITableViewController *superVC;
@property(nonatomic , weak)UILabel *remind;
@end

@implementation LYtouchID_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    UIImage *bgImag = [UIImage imageNamed:@"placeholder_skype"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImag];
    UILabel *remind = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    remind.text = @"Touch To Unlock";
    remind.textColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    remind.font = [UIFont fontWithName:@"Helvetica" size:30];
    [self.view addSubview:remind];
    [remind sizeToFit];
    remind.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.remind = remind;
    [self wakeTouchID];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self wakeTouchID];
}

-(void)wakeTouchID{
    //1.判断系统版本
    //2.判断系统是否支持
    LAContext *context = [[LAContext alloc]init];
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil] || [UIDevice currentDevice].systemVersion.floatValue<8.0) {
        return;
    }
    //3.验证用户指纹
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"指纹验证后使用" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //成功后回到主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.remind.text = @"";
                [UIView animateWithDuration:1.2 animations:^{
                    self.view.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }completion:^(BOOL finished) {
                    [self.navigationController popViewControllerAnimated:NO];
                }];
            });
            
        }else{
            //TODO 其他各种情况的失败处理
        }
        
    }];
}

//隐藏各种
- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationItem setHidesBackButton:NO];
}

@end
