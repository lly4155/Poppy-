//
//  LoopViewLayout.m
//  图片无限轮播
//
//  Created by LLy on 16/5/31.
//  Copyright © 2016年 LLy. All rights reserved.
//

#import "LoopViewLayout.h"

@implementation LoopViewLayout

-(void)prepareLayout{
    [super prepareLayout];
    //设置item尺寸
    self.itemSize = self.collectionView.frame.size;
    //设置滚动方向
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置分页
    self.collectionView.pagingEnabled = YES;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    //设置隐藏水平条
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

@end
