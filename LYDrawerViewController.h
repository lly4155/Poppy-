//
//  LYDrawerViewController.h
//  Poppy网易
//
//  Created by LLy on 2017/1/10.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

@interface LYDrawerViewController : MSDynamicsDrawerViewController
//  分享标题
@property (nonatomic, strong) NSString *shareTitle;

//  分享文本
@property (nonatomic, strong) NSString *shareText;

//  分享链接
@property (nonatomic, strong) NSString *shareUrl;

/**
 *  返回抽屉控制器
 */
+ (instancetype)sharedDrawer;

-(void)closecloseLeftMenuWithDuration:(CGFloat)duration;
@end
