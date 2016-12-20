//
//  HMNewsCell.m
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "HMNewsCell.h"
#import <UIImageView+WebCache.h>
#import "HMNews.h"
#import "LoopView.h"

@interface HMNewsCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *digestLabel;

@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *extraImageViews;



@end

@implementation HMNewsCell

- (void)setNews:(HMNews *)news{
    _news = news;
    //图片填充不失真
    [self.iconImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.iconImageView.clipsToBounds = YES;
    
    //给相应的控件赋值
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:news.imgsrc]placeholderImage:[UIImage imageNamed:@"placeholder_dropbox"]];
    
    self.titleLabel.text = news.title;
    
    self.digestLabel.text = news.digest;
    
    // 如果回复太多就改成几点几万
    NSInteger temp = news.replyCount;
    NSString *displayCount;
    if (temp > 10000) {
        displayCount = [NSString stringWithFormat:@"%.1ld万跟帖",temp/10000];
    }else if (temp == 0)
        displayCount = @"0跟帖";
    else{
        displayCount = [NSString stringWithFormat:@"%.0ld跟帖",(long)temp];
    }
    self.replyCountLabel.text = displayCount;
    self.replyCountLabel.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0];
    self.replyCountLabel.layer.cornerRadius = 3;
    self.replyCountLabel.layer.masksToBounds = YES;
    
    if (news.imgextra.count == 2) {
        for (int i = 0; i < news.imgextra.count; ++i) {
            NSDictionary *dict = news.imgextra[i];
            
            //根据dict取出对应的imgsrc,设置到对应的控件上
            NSString *imageURLString = dict[@"imgsrc"];
            
            [self.extraImageViews[i] sd_setImageWithURL:[NSURL URLWithString:imageURLString]placeholderImage:[UIImage imageNamed:@"placeholder_dropbox"]];
        }
    }
    //设置背景颜色
    self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
}

@end
