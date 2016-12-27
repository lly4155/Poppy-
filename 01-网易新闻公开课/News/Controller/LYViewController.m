//
//  LYViewController.m
//  Poppy网易
//
//  Created by LLy on 2016/11/3.
//  Copyright © 2016年 itcast. All rights reserved.
//
#import "LYViewController.h"
#import "LyPhotoViewController.h"
#import "LyNewsViewController.h"
#import "LyWalletViewController.h"
#import "LYChannelView.h"
#import "LYChannelModel.h"
#import "YYModel.h"
#import "LYCollectionViewCell.h"
#import "CBStoreHouseRefreshControl.h"
#import "HMDrawerViewController.h"
#import "LyMeVC.h"//其实是聊天视图，没改名
#import "PYSearch.h"//搜索框

@interface LYViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,LYChannelViewDelegate,PYSearchViewControllerDelegate>
@property (nonatomic,strong) NSMutableArray *innerNewsList;//存数据源
@property (nonatomic,strong) NSArray<NSString*> *hotSeaches;//存频道名字，用于搜索
@property (weak, nonatomic) IBOutlet LYChannelView *channelView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//下拉刷新
//频道模型
@property (nonatomic,strong) NSArray<LYChannelModel *> *channel;
@end

@implementation LYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"top_navigation_infoicon"] style:UIBarButtonItemStylePlain target:self action:@selector(openMe:)];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.frame = CGRectMake(0, 35, self.view.frame.size.width, self.view.frame.size.height);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushWallet) name:@"pushWallet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushChatView) name:@"pushChatView" object:nil];
    self.collectionView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    //设置返回按钮的文字
    UIBarButtonItem *returnBtn = [[UIBarButtonItem alloc]init];
    returnBtn.title = @"返回";
    self.navigationItem.backBarButtonItem = returnBtn;
    
    // 给频道视图设置数据
    self.channelView.channels = self.channel;
    self.channelView.delegate = self;
    [self.channelView setScale:1 forIndex:0];
    
    //给collectionView添加左滑菜单
    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc]init];
    ges = [[HMDrawerViewController sharedDrawer] addScreenEdgePanGestureRecognizerToView:self.collectionView];
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:ges];
}

//懒加载
- (NSArray<LYChannelModel *> *)channel{
    if (!_channel) {
        // 1. 读取文件路径
        NSString *file = [[NSBundle mainBundle] pathForResource:@"topic_news.json" ofType:nil];
        // 2. 读取文件的内容
        NSData *data = [NSData dataWithContentsOfFile:file];
        // 3. 将二进制数据转成模型数组
        // YYModel --> 多线程网络的课程中
        NSArray *array = [NSArray yy_modelArrayWithClass:[LYChannelModel class] json:data];
        NSMutableArray *MtbArrary = [array mutableCopy];
        for (LYChannelModel *model in array) {//把头条放在最前面
            if ([model.tname isEqualToString:@"头条"]) {
                [MtbArrary exchangeObjectAtIndex:0 withObjectAtIndex: [MtbArrary indexOfObject:model]];
                break;
            }
        }
        array = [MtbArrary copy];
        _channel = array;
    }
    return _channel;
}

//打开我的菜单
-(void)openMe:(id)sender{
    [[HMDrawerViewController sharedDrawer]openLeftMenuWithDuration:0.5 completion:^{
        
    }];
}

//more按钮
- (IBAction)moreBtn {
    //建立一个搜索话题的搜索框，点击后直接跳转到相应频道
    //1.设置可搜索的频道内容
    NSMutableArray *channelID = [NSMutableArray array];
    for (NSInteger i=0; i<self.channel.count; i++) {
        [channelID addObject:self.channel[i].tname];
    }
    NSArray *hotSeaches = [channelID copy];
    self.hotSeaches = hotSeaches;
    //2.创建控制器
    PYSearchViewController *searchViewController = [PYSearchViewController searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:@"搜索频道" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        //点击搜索后，执行相应操作
        double delayInSeconds = 0.5;//为了使主页动画显示出来，需要延迟执行
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            for (NSInteger i=0; i<hotSeaches.count; i++) {
                if ([searchText isEqualToString:hotSeaches[i]]) {
                    [self channelView:self.channelView clickWithIndex:i];
                    [self.channelView tapViewtTo:i];
                    break;
                }
            }
        });
    }];
    //3.设置风格
    searchViewController.hotSearchStyle = PYHotSearchStyleColorfulTag;
    searchViewController.searchHistoryStyle = PYSearchHistoryStyleBorderTag;
    searchViewController.delegate = self;
    //4.跳转到搜索控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:nav  animated:NO completion:nil];
}

#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) { // 与搜索条件再搜索
        // 根据条件发送查询
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 搜索完毕
            // 显示建议搜索结果
            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
            for (int i = 0; i < self.hotSeaches.count; i++) {
                //一次遍历一个子串, 而不是遍历一个unichar
                NSRange range;
                for (int j = 0; j < self.hotSeaches[i].length; j+=range.length) {
                    range = [self.hotSeaches[i] rangeOfComposedCharacterSequenceAtIndex:j];
                    if ([searchText containsString: [self.hotSeaches[i] substringWithRange:range]]) {
                        //保证搜索数组不包含重复的元素，使用predicate快速查找
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", self.hotSeaches[i]];
                        NSArray *array =[searchSuggestionsM filteredArrayUsingPredicate:predicate];
                        if(array.count == 0){
                            [searchSuggestionsM addObject:self.hotSeaches[i]];
                        }
                    }
                }
            }
            // 返回
            searchViewController.searchSuggestions = searchSuggestionsM;
        });
    }
}

/**
 当前控制器的view 在布局子视图的时候会调用
 */
 
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 因为在这个时候，collectionView 的大小已经确定了
    // 1. 取到布局对象
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.collectionView collectionViewLayout];
    // 2. 设置大小
    layout.itemSize = self.collectionView.frame.size;
}

#pragma mark - UICollectionViewDataSource

// 控件器告诉 collectionView 一共有多少条数据
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.channel.count;
}

//隐藏显示tabbar
- (void)setTabBarHidden:(BOOL)hidden
{
    UIView *tab = self.tabBarController.view;
    CGRect  tabRect=self.tabBarController.tabBar.frame;
    if ([tab.subviews count] < 2) {
        return;
    }
    
    UIView *view;
    if ([[tab.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        view = [tab.subviews objectAtIndex:1];
    } else {
        view = [tab.subviews objectAtIndex:0];
    }
    
    if (hidden) {
        view.frame = tab.bounds;
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height+self.tabBarController.tabBar.frame.size.height;
    } else {
        view.frame = CGRectMake(tab.bounds.origin.x, tab.bounds.origin.y, tab.bounds.size.width, tab.bounds.size.height);
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height-self.tabBarController.tabBar.frame.size.height;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.tabBarController.tabBar.frame=tabRect;
    }completion:^(BOOL finished) {
        
    }];
    
}

// 告诉 collectionView 对应位置的内容是什么
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"channelCell" forIndexPath:indexPath];
    
    cell.channelID = self.channel[indexPath.row].tid;
    
    cell.setTabBarHidden = ^(BOOL hidden){
        [self setTabBarHidden:hidden];
    };
    cell.segueJump = ^(NSString *name,NSString *url,NSNumber *replyNum){
        if ([name isEqualToString:@"news"]) {
            LyNewsViewController *vc = [[LyNewsViewController alloc]initWithURLStrs:url];
            [self.navigationController pushViewController:vc animated:YES];
        }else if([name isEqualToString:@"photoSet"]){
            LyPhotoViewController *vc = [[LyPhotoViewController alloc]initWithURLStrs:url reply:replyNum];
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    
    return cell;
}


-(void)pushWallet{
    LyWalletViewController *wallet = [[LyWalletViewController alloc]init];
    [self.navigationController pushViewController:wallet animated:NO];
}

-(void)pushChatView{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LyMeVC *chatVC = [sb instantiateViewControllerWithIdentifier:@"myChat"];
    [self.navigationController pushViewController:chatVC animated:NO];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"滚动了 %f 距离",scrollView.contentOffset.x);
    
    // 先计算出整体的比例
    CGFloat ratio = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    // 计算出在当前的索引(去除小数部分)
    NSInteger index = ratio / 1;
    
    // 变化的比例
    CGFloat scale = ratio - index;
    // NSLog(@"整体的比例 %f, 索引 %zd, 比例 %f", ratio, index, scale);
    
    if (index + 1 < self.channel.count) {
        // 设置 index + 1 的文字颜色变红，并且字体变大
        [self.channelView setScale:scale forIndex:index + 1];
        [self.channelView setScale:1 - scale forIndex:index];
    }
}

#pragma mark - channelViewDelegate
- (void)channelView:(LYChannelView *)view clickWithIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    self.collectionView.delegate = nil;
    // 要滚动到指定的位置
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:0 animated:false];
    self.collectionView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
//    [self setTabBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
//    [self setTabBarHidden:YES];
}

@end
