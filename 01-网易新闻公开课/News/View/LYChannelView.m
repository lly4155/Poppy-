//
//  LYChannelView.m
//  Poppy网易
//
//  Created by LLy on 2016/11/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LYChannelView.h"
#import "CZAdditions.h"
#import "LYChannelModel.h"

@interface LYChannelView()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation LYChannelView

// 外界设置 channels 的时候，就会调用这个方法
- (void)setChannels:(NSArray *)channels{
    _channels = channels;
    self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    CGFloat offsetX = 20;
    for (LYChannelModel *model in channels) {
        //1.初始化控件
        UILabel *label = [UILabel cz_labelWithText:model.tname fontSize:18 color:[UIColor blackColor]];
        // 2.调整控件的位置和大小
        [label sizeToFit];
        label.font = [UIFont systemFontOfSize:14];
        CGRect frame = label.frame;
        frame.origin.x = offsetX;
        frame.size.height = 35;
        label.frame = frame;
        // 给 label 添加一个点击的手势
        UIGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [label addGestureRecognizer:ges];
        // 开启用户交互
        label.userInteractionEnabled = YES;
        // 3. 添加到滚动视图中
        [self.scrollView addSubview:label];
        // 4. 递增 label 的 x 值
        offsetX += 10 + label.frame.size.width;
    }
    
    // 设置 滚动视图的 contentSize,告诉滚动视图能够滚动的距离
    self.scrollView.contentSize = CGSizeMake(offsetX, 35);
    // 设置索引为0的 label 的缩放比为1
    
}
//供外界改变频道视图变化的动画
- (void)tapViewtTo:(NSInteger)index{
    [UIView animateWithDuration:0.25 animations:^{
        for (int i=0; i<self.scrollView.subviews.count; i++) {
            if (index == i) {
                // 如果 当前遍历到的 label 是点击的 label,那么就放大
                [self setScale:1 forIndex:i];
            }else {
                [self setScale:0 forIndex:i];
            }
        }
    }];
    // 取到对应索引 的 label
    UILabel *label = self.scrollView.subviews[index];
    [self scrollToCenter:label];
}

- (void)tap:(UITapGestureRecognizer *)ges{
    // 应该把事件抛给控制器
    // 代理 ，通知， block
    
    NSInteger index = [self.scrollView.subviews indexOfObject:ges.view];
    
//    NSLog(@"index = %zd",index);
    // 先判断是否有实现该方法
    if ([self.delegate respondsToSelector:@selector(channelView:clickWithIndex:)]) {
        // 如果已实现该方法，那就么调用
        [self.delegate channelView:self clickWithIndex:index];
    }
    
    // 在点击的时候，让点击的按钮放大，其他按钮缩小
    
    [UIView animateWithDuration:0.25 animations:^{
        for (int i=0; i<self.scrollView.subviews.count; i++) {
            UILabel *label = self.scrollView.subviews[i];
            if (label == ges.view) {
                // 如果 当前遍历到的 label 是点击的 label,那么就放大
                [self setScale:1 forIndex:i];
            }else {
                [self setScale:0 forIndex:i];
            }
        }
    }];
    
    
    [self scrollToCenter:ges.view];
}

- (void)setScale:(CGFloat)scale forIndex:(NSInteger)index {
    
    // 1. 取到对应索引 的 label
    UILabel *label = self.scrollView.subviews[index];
    // 2. 设置颜色
    label.textColor = [UIColor colorWithRed:scale green:0 blue:0 alpha:1];
    // 3. 设置大小
    
    // 当 scale 为 0 的时候，大小为 14
    // 当 scale 为 1 的时候，大小为 18
    // 当 scale 为 0.5 的时候，大小为 14 + (18 - 14) * 0.5
    
    // 字体大小
    CGFloat fontSize = 14 + (18 - 14) * scale;
    label.transform = CGAffineTransformMakeScale(fontSize / 14, fontSize / 14);
    
    [self scrollToCenter:label];
}


/**
 滚动指定的视图到中间
 */
- (void)scrollToCenter:(UIView *)view {
    
    // 要让 scrollView 显示 指定的位置，可以设置 scrollView 的 contentOffset.x
    
    // nba 的中心点 - scrollView.width * 0.5
    CGFloat offsetX = view.center.x - self.scrollView.frame.size.width * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
}

@end
