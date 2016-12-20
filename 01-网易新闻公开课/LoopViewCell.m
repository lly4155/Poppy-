//
//  LoopViewCell.m
//  图片无限轮播
//
//  Created by LLy on 16/5/31.
//  Copyright © 2016年 LLy. All rights reserved.
//

#import "LoopViewCell.h"
#import "UIImageView+WebCache.h"

@interface LoopViewCell()
@property (nonatomic,weak) UIImageView *iconView;
@property (nonatomic,weak) UILabel *text;
@end

@implementation LoopViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //创建图片
        UIImageView *iconView = [[UIImageView alloc]init];
        //将图片添加到当前cell
        [self addSubview:iconView];
        self.iconView = iconView;
        //添加标题
        UILabel *text = [[UILabel alloc]init];
        text.backgroundColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.5];
        text.textColor = [UIColor whiteColor];
        [self addSubview:text];
        self.text = text;
    }
    return self;
}

-(void)setUrlS:(NSString *)urlS{
    _urlS = urlS;
    //下载图像
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:_urlS] placeholderImage:[UIImage imageNamed:@"placeholder_dropbox"]];
}

- (void)setUrlText:(NSString *)urlText{
    _urlText = urlText;
    _text.text = [NSString stringWithFormat:@"  %@",_urlText];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.iconView.frame = self.bounds;
    self.text.frame = CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30);
}

@end
