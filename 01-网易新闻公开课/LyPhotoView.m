//
//  LyPhotoView.m
//  Poppy网易
//
//  Created by LLy on 16/8/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyPhotoView.h"
#import "LyPhotoCollectionViewCell.h"
#import "LyPhotoLayout.h"

@interface LyPhotoView() <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *urlStrs;
@end

@implementation LyPhotoView

- (instancetype)initWithURLStrs:(NSMutableArray *)URLStrs{
    if (self = [super init]) {
        //创建collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[LyPhotoLayout alloc]init]];
        //设置背景
        collectionView.backgroundColor = [UIColor blackColor];
        //注册一个cell
        [collectionView registerClass:[LyPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        //设置数据源
        collectionView.dataSource = self;
        //设置代理
        collectionView.delegate = self;
        
        //将collectionView添加到当前控件上
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        //记录数组
        self.urlStrs = URLStrs;
    }
    return self;
}

#pragma mark -collectionViewDelegate重写方法

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //获得偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    //计算当前显示的页数
    self.index = offsetX / scrollView.bounds.size.width;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"nextConent" object:nil];
}

//数据源方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.urlStrs.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //从缓冲池获得cell
    LyPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //将图片url传递给cell
    cell.urlS = self.urlStrs[indexPath.item];
    //给collectionView添加左滑菜单
//    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(edgePanGes:)];
//    ges.edges = UIRectEdgeLeft;
//    [cell addGestureRecognizer:ges];
//    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:ges];
    return cell;
}

/**
 *  手势识别回调方法
 */
- (void)edgePanGes:(UIScreenEdgePanGestureRecognizer *)pan {
    // 获得x方向拖动的距离
    CGFloat offsetX = [pan translationInView:pan.view].x;
    // 限制offsetX的最大值为leftWidth
    //    offsetX = MIN(self.leftWidth, offsetX);
    // 判断手势的状态
    if(pan.state == UIGestureRecognizerStateChanged) {
        // 手势一直处于改变状态
        [self viewController].view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
        //        self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        // 手势结束或手势被取消了
        // 获得mainVc的x值
        //        CGFloat mainX = self.mainVc.view.frame.origin.x;
        if (offsetX >= self.frame.size.width * 0.3) { // 超过屏幕的一半
            [self back:pan];
        } else {
            [self viewController].view.transform = CGAffineTransformMakeTranslation(0, 0);
        }
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

-(void)back:(UIScreenEdgePanGestureRecognizer *)ges{
    [[self viewController].navigationController popViewControllerAnimated:YES];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //设置frame
    self.collectionView.frame = self.bounds;
}

@end
