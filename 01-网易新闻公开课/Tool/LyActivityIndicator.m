//
//  LyActivityIndicator.m
//  Poppy网易
//
//  Created by LLy on 16/7/15.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyActivityIndicator.h"

@implementation LyActivityIndicator
- (instancetype)initWithFrame:(CGRect)frame{
     if (self = [super initWithFrame:frame]) {
         self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-25, [UIScreen mainScreen].bounds.size.height/2-25, 50 , 50);
         self.backgroundColor = [UIColor lightGrayColor];
         self.layer.cornerRadius = 10;
         // 菊花的颜色和格式（白色、白色大、灰色）
         self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        // 在菊花下面添加文字
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(-12, 40, 80, 40)];
        label.text = @"loading...";
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [self addSubview:label];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
