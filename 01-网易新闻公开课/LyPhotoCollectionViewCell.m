//
//  LyPhotoCollectionViewCell.m
//  Poppy网易
//
//  Created by LLy on 16/8/6.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyPhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface LyPhotoCollectionViewCell()
@property (nonatomic,weak) UIImageView *iconView;
@end

@implementation LyPhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //创建图片
        UIImageView *iconView = [[UIImageView alloc]init];
        iconView.contentMode =  UIViewContentModeScaleAspectFit;
        //将图片添加到当前cell
        [self addSubview:iconView];
        self.iconView = iconView;
    }
    return self;
}

-(void)setUrlS:(NSString *)urlS{
    _urlS = urlS;
    //下载图片时，网络不好出现菊花
    __block UIActivityIndicatorView *activityIndicator;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:_urlS] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (!activityIndicator)
        {
            [self.iconView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
            activityIndicator.center = self.iconView.center;
            [activityIndicator startAnimating];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [activityIndicator removeFromSuperview];
        activityIndicator = nil;
    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.iconView.frame = self.bounds;
}

@end
