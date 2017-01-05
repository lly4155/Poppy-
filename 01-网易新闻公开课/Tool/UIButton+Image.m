//
//  UIButton+Image.m
//  Poppy网易
//
//  Created by Alex_LLy on 2017/1/5.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import "UIButton+Image.h"

@implementation UIButton (Image)
- (void)setBackgroundImage:(UIImage*)image
{
    CGRect rect;
    rect = self.frame;
    rect.size = image.size; // set button size as image size
    self.frame = rect;
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setBackgroundImageByName:(NSString*)imageName
{
    [self setBackgroundImage:[UIImage imageNamed:imageName]];
}
@end
