//
//  LYChannelView.h
//  Poppy网易
//
//  Created by LLy on 2016/11/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYChannelView;
@protocol LYChannelViewDelegate <NSObject>
/**
 当频道视图中的 label 点击的时候会调用
 
 @param view  频道视图
 @param index 索引 --> 代表点击了哪一个 label
 */
- (void)channelView:(LYChannelView *)view clickWithIndex:(NSInteger)index;
@end

@interface LYChannelView : UIView

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, weak) id<LYChannelViewDelegate> delegate;
/**
 设置索引对应 label 的比例
 
 @param scale 比例
 @param index 索引
 */
- (void)setScale:(CGFloat)scale forIndex:(NSInteger)index;
- (void)tapViewtTo:(NSInteger)index;
@end
