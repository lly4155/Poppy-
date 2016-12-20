//
//  LoopView.m
//  图片无限轮播
//
//  Created by LLy on 16/5/31.
//  Copyright © 2016年 LLy. All rights reserved.
//

#import "LoopView.h"
#import "LoopViewLayout.h"
#import "LoopViewCell.h"
#import "WeakTimerTargetObj.h"
#import "LyPhotoViewController.h"

@interface LoopView() <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) UIPageControl *pageCtl;
@property (nonatomic,strong) NSArray *urlStrs;
@property (nonatomic,strong) NSArray *Text;
@property (nonatomic,strong) NSArray *photoSet;
@property (nonatomic,strong) NSArray *urlTag;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) NSTimer *timer;//定时器
@end

@implementation LoopView
/**
 *  初始化方法
 *
 *  @param URLStrs 图片数组（URL）
 *  @param titles  标题数组
 *
 *  @return 轮播器对象
 */


- (instancetype)initWithURLStrs:(NSArray *)URLStrs titles:(NSArray *)titles url:(NSArray *)url tag:(NSArray *)tag{
    if (self = [super init]) {
        //创建collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[LoopViewLayout alloc]init]];
        //设置背景
        collectionView.backgroundColor = [UIColor whiteColor];
        //注册一个cell
        [collectionView registerClass:[LoopViewCell class] forCellWithReuseIdentifier:@"cell"];
        //设置数据源
        collectionView.dataSource = self;
        //设置代理
        collectionView.delegate = self;
        
        //将collectionView添加到当前控件上
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.urlStrs.count inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:NO];
        });
      
        //记录数组
        self.urlStrs = URLStrs;
        self.Text = titles;
        self.photoSet = url;
        self.urlTag = tag;
        [self addTimer];
    }
    return self;
}
//添加定时器
-(void)addTimer{
    if (self.timer){
        return;
    }
    self.timer = [WeakTimerTargetObj scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)nextImage{
    //获得偏移量
    CGFloat offsetX = self.collectionView.contentOffset.x;
    //计算当前显示的页数
    NSInteger page = offsetX / self.collectionView.bounds.size.width;
    
    [self.collectionView setContentOffset:CGPointMake((page+1) * self.collectionView.frame.size.width, 0) animated:YES];
    
}

#pragma mark -collectionViewDelegate重写方法
//手势开始时
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}

//滚动结束时调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}

//滚动减速时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //获得偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    //计算当前显示的页数
    NSInteger page = offsetX / scrollView.bounds.size.width;
    //更新分页
    self.pageCtl.currentPage = page % self.urlStrs.count;
    //移动到最前面或者最后面的时候修改偏移量
    if (page == 0) {
        page = self.urlStrs.count;
        self.collectionView.contentOffset = CGPointMake(page * self.collectionView.frame.size.width, 0);
    }else if (page == [self.collectionView numberOfItemsInSection:0]-1){
        page = self.urlStrs.count - 1;
        self.collectionView.contentOffset = CGPointMake(page * self.collectionView.frame.size.width, 0);
    }
    [self addTimer];
}

//数据源方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.urlStrs.count * 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //从缓冲池获得cell
    LoopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //传递URL字符串
    cell.urlS = self.urlStrs[indexPath.item % self.urlStrs.count];
    cell.urlText = self.Text[indexPath.item % self.urlStrs.count];
    
    //页数改动的时候，同时刷新pageCtl
    self.index = indexPath.item % self.urlStrs.count;
    return cell;
}

//点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.urlTag[indexPath.row % self.urlStrs.count] isEqualToString:@"doc"]) {
        //TODO 如果是文档型的，不是图片则进行相应的跳转
        
    }else{
    NSNumber *reply = [NSNumber numberWithInt: -1];
    LyPhotoViewController *vc = [[LyPhotoViewController alloc]initWithURLStrs:self.photoSet[indexPath.row % self.urlStrs.count] reply:reply];
    [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}
    
//获取该view的上一级控制器
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //设置frame
    self.collectionView.frame = self.bounds;

    //添加pageControl
    UIPageControl *pageCtl = [[UIPageControl alloc]init];
    //设置居右
    CGSize pointSize = [pageCtl sizeForNumberOfPages:self.urlStrs.count];
    pageCtl.frame = CGRectMake(self.frame.size.width-pointSize.width-10, self.frame.size.height-30, pointSize.width, 30);
    //设置pageCtl的属性
    pageCtl.numberOfPages = self.urlStrs.count;
    pageCtl.pageIndicatorTintColor = [UIColor colorWithRed:185/255.0 green:185/255.0 blue:185/255.0 alpha:1.0];
    pageCtl.currentPageIndicatorTintColor = [UIColor whiteColor];
    //缩放pageCtl的点的大小
    pageCtl.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    //修改触摸事件，使其不变化
    [pageCtl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:pageCtl];
    self.pageCtl = pageCtl;
}

- (void) changePage{
    //不让触摸
    self.pageCtl.currentPage = self.index;
}


@end
