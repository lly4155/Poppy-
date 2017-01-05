//
//  UINavigationBar+backGroundColor.m
//  Poppy网易
//
//  Created by Alex_LLy on 2016/12/28.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "UINavigationBar+backGroundColor.h"
#import <objc/runtime.h>

//解决NavigationBar颜色设置不一致的问题，该问题主要是因为NavigationBar有透明度导致的
@implementation UINavigationBar (backGroundColor)
static char overlayKey;

- (UIView *)overlay
{    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setOverlay:(UIView *)overlay{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lt_setBackgroundColor:(UIColor *)backgroundColor
{
    if (!self.overlay) {
        [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[[UIImage alloc] init]];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 64)];
        self.overlay.userInteractionEnabled = NO;
        [self insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}
@end
