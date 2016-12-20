//
//  HMNewsTableViewController.m
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/9.
//  Copyright © 2016年 itcast. All rights reserved.
//
#import "LyPhotoViewController.h"
#import "LyNewsViewController.h"
#import "HMNewsTableViewController.h"
#import "HMNews.h"
#import "HMNewsCell.h"
#import "LoopView.h"
#import "MGSwipeTableCell.h"
#import "MJRefresh.h"
#import "CBStoreHouseRefreshControl.h"
#import "LyActivityIndicator.h"
#import "UIScrollView+EmptyDataSet.h"
#import "LyWalletViewController.h"
#define LQXWidth self.view.bounds.size.width
#define LQXHeight self.view.bounds.size.height

@interface HMNewsTableViewController () <MGSwipeTableCellDelegate,UIWebViewDelegate,UIScrollViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic,strong) NSMutableArray *innerNewsList;//存数据源
//@property (nonatomic , assign) BOOL firstShow;//解决cell的第一次画面出现第一行的选择问题
@property (nonatomic,assign) NSInteger urlNum;//刷新的网址区分下标
@property (nonatomic , strong) LoopView *loopView;//轮播器
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;//下拉刷新
@property(nonatomic,assign)CGFloat historyY;
@end

@implementation HMNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushWallet) name:@"pushWallet" object:nil];
    self.urlNum = 0;
//    _firstShow = YES;
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:238/255.0 alpha:1];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    //设置返回按钮的文字
    UIBarButtonItem *returnBtn = [[UIBarButtonItem alloc]init];
    returnBtn.title = @"返回";
    self.navigationItem.backBarButtonItem = returnBtn;

    //加载数据
    __weak typeof(self) weakSelf = self;
    [HMNews newsListWithURLString:@"article/headline/T1348647853363/0-20.html" completeBlock:^(NSMutableArray *newsList) {
        //赋值给控制器的innerNewsList
        _innerNewsList = newsList;
        [self loadHeaderView];
        //刷新表格
        [weakSelf.tableView reloadData];
    }];
    
    //上拉加载
    self.tableView.mj_footer.hidden = YES;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    //下拉刷新
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(refreshTriggered:) plist:@"storehouse" color:[UIColor whiteColor] lineWidth:1.5 dropHeight:80 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    
    //长按移动
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
}

#pragma mark - move methods
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.innerNewsList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.innerNewsList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                cell.hidden = NO;
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


#pragma mark - Data Source Implementation
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"placeholder_dropbox"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}


#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.storeHouseRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.storeHouseRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Listening for the user to trigger a refresh

- (void)refreshTriggered:(id)sender
{
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
}

- (void)finishRefreshControl
{
    [self.storeHouseRefreshControl finishingLoading];
    NSInteger randomNum = (arc4random()%40)*10;
    NSString *newUrl = [NSString stringWithFormat:@"article/headline/T1348647853363/%ld-20.html",randomNum];
    [HMNews newsListWithURLString:newUrl completeBlock:^(NSMutableArray *newsList) {
        //赋值给控制器的innerNewsList
        _innerNewsList = newsList;
        [self.loopView removeFromSuperview];
        [self loadHeaderView];
        //刷新表格
        [self.tableView reloadData];
    }];
}


//MJ下拉刷新方法
-(void)loadData{
    // http://c.m.163.com//nc/article/headline/T1348647853363/0-20.html
    NSInteger randomNum = (arc4random()%40)*10;
    NSString *newUrl = [NSString stringWithFormat:@"article/headline/T1348647853363/%ld-20.html",randomNum];
    [HMNews newsListWithURLString:newUrl completeBlock:^(NSMutableArray *newsList) {
        //赋值给控制器的innerNewsList
        _innerNewsList = newsList;
        [self.loopView removeFromSuperview];
        [self loadHeaderView];
        //刷新表格
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
}

//上拉加载方法
-(void)loadMoreData{
    self.urlNum += 20;
    if (self.urlNum <= 400) {
        NSString *newUrl = [NSString stringWithFormat:@"article/headline/T1348647853363/%ld-20.html",self.urlNum];
        [HMNews newsListWithURLString:newUrl completeBlock:^(NSMutableArray *newsList) {
            //赋值给控制器的innerNewsList
            [self.innerNewsList addObjectsFromArray:newsList];
            [self.tableView.mj_footer endRefreshing];
            //刷新表格
            [self.tableView reloadData];
        }];
    }
}

-(void)pushWallet{
    LyWalletViewController *wallet = [[LyWalletViewController alloc]init];
    [self.navigationController pushViewController:wallet animated:NO];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)loadHeaderView{
    //添加tableViewHeader
    HMNews *headNews = self.innerNewsList[0];
    
    NSArray *adImageURL = [headNews.ads valueForKeyPath:@"imgsrc"];
    
    NSArray *adTitle = [headNews.ads valueForKeyPath:@"title"];
    
    NSArray *url = [headNews.ads valueForKeyPath:@"url"];
    
    NSArray *urlTag = [headNews.ads valueForKeyPath:@"tag"];

    LoopView *loopView = [[LoopView alloc] initWithURLStrs:adImageURL titles:adTitle url:url tag:urlTag];
    
    loopView.frame = CGRectMake(0, 20, self.view.frame.size.width, 200);
    
    self.loopView = loopView;
    //添加到tableView中
    self.tableView.tableHeaderView = loopView;
}

#pragma mark - scrollViewDelegate
//设置滑动的判定范围
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (_historyY+20<targetContentOffset->y)
    {
        [self setTabBarHidden:YES];
    }
    else if(_historyY-20>targetContentOffset->y)
    {
        [self setTabBarHidden:NO];
    }
    _historyY=targetContentOffset->y;
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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return self.innerNewsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    
    //根据模型来决定展示什么样的cell
    HMNews *news = self.innerNewsList[indexPath.row];
    
    if (news.imgType) {
        identifier = @"BigCell";
    }else if(news.imgextra.count == 2){
        identifier = @"ThreeCell";
    }else{
        identifier = @"BaseCell";
    }

    HMNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.news = news;
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
                          [MGSwipeButton buttonWithTitle:@"Top" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.delegate = self;
    return cell;
}
//2个侧滑按钮的功能实现
-(BOOL) swipeTableCell:(HMNewsCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (index == 0) {
        [self.innerNewsList removeObjectAtIndex:path.row];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }else if (index == 1 && path.row != 0){
        //首行的path
        NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
        //要置顶的对象先保存
        NSObject *obj = [self.innerNewsList objectAtIndex:path.row];
        //在源数据里删除要置顶的对象
        [self.innerNewsList removeObjectAtIndex:path.row];
        //cell动画删除该行
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.innerNewsList exchangeObjectAtIndex:path.row withObjectAtIndex:0];
        //置顶的数据插入到第一行
        [self.innerNewsList insertObject:obj atIndex:0];
        [self.tableView reloadData];
        //更新
//        [self.tableView reloadRowsAtIndexPaths:@[first] withRowAnimation:UITableViewRowAnimationRight];
        //滚动到顶部
        [self.tableView scrollToRowAtIndexPath:first atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HMNews *news = self.innerNewsList[indexPath.row];
    if (news.imgType) {
        return 200;
    }else if(news.imgextra.count == 2){
        return 120;
    }else{
        return 90;
    }
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 刚选中又马上取消选中，格子不变色
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HMNews *news = self.innerNewsList[indexPath.row];
    NSString *url_3w = news.url_3w;
    NSString *url = news.url;
    NSString *loadUrl = nil;
    if (!url_3w) {
        loadUrl = url;
    }else{
        loadUrl = url_3w;
    }
    NSString *photosetID = news.photosetID;
    
    //对应跳转
    if (loadUrl) {
        [self performSegueWithIdentifier:@"news" sender:loadUrl];
    }else if(photosetID){
        NSInteger replay = news.replyCount;
        NSNumber *aNumber = [NSNumber numberWithInteger:replay];
        NSMutableArray *send = [[NSMutableArray alloc]initWithCapacity:2];
        [send addObject:photosetID];
        [send addObject:aNumber];
        [self performSegueWithIdentifier:@"photoSet" sender:send];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSLog(@"%@",sender);
    
    if ([segue.identifier  isEqual: @"news"]) {
        LyNewsViewController *vc = segue.destinationViewController;
        [vc setValue:sender forKey:@"url"];
    }
    
    if ([segue.identifier  isEqual: @"photoSet"]) {
        LyPhotoViewController *vc = segue.destinationViewController;
        [vc setValue:sender forKey:@"senderAPI"];
    }
    
}

//tableViewCell的显示动画
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//
    NSArray *array = tableView.indexPathsForVisibleRows;
    
    NSIndexPath *firstIndexPath = array[0];
//
//    //设置anchorPoint
//    
//    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    
//    //为了防止cell视图移动，重新把cell放回原来的位置
//    
//    cell.layer.position = CGPointMake(0, cell.layer.position.y);
//    
//    //设置cell
//    //按照z轴旋转90度，注意是弧度
//    if(firstIndexPath.row < indexPath.row)
//    {
//        cell.layer.transform = CATransform3DMakeRotation(M_PI_4,0,0,1.0);
//    }else{
//        if (self.firstShow) {
//            cell.layer.transform = CATransform3DMakeRotation(M_PI_4,0,0,1.0);
//            self.firstShow = NO;
//        }else
//        cell.layer.transform = CATransform3DMakeRotation(-M_PI_4,0,0,1.0);
//    }
//
//    cell.alpha = 0.0;
//    [UIView animateWithDuration:0.5 animations:^{
//            cell.layer.transform = CATransform3DIdentity;
//            cell.alpha = 1.0;
//        }];
    
    
    if(firstIndexPath.row < indexPath.row){
        cell.layer.transform = CATransform3DMakeTranslation(0, 80, 0);
        cell.alpha = 0.1;
        [UIView animateWithDuration:0.2 animations:^{
            cell.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
            cell.alpha = 1.0;
        }];
    }
}

@end
