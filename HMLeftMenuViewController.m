//
//  HMLeftMenuViewController.m
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import "HMNewsTableViewController.h"
#import "HMLeftMenuViewController.h"
#import "HMLeftItem.h"
#import "HMDrawerViewController.h"

@interface HMLeftMenuViewController()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, retain) UILabel *cacheLabel;
@property (nonatomic, weak) UIImageView *headerImg;
@end

@implementation HMLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"reload" object:nil];
    // 隐藏分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置背景图片，将图片设置成填充模式
    //1.从layer层入手，改变contents
    self.tableView.layer.contents = (id)[UIImage imageNamed:@"Stars.jpg"].CGImage;
    //2.重绘图层
    UIImage *img = [UIImage imageNamed:@"Stars.jpg"];
    UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, NO, 0.0f);
    [img drawInRect:self.tableView.bounds];
    UIImage *lastImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:lastImg];
    // 创建表格头部视图
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    UIImageView *headerImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [headerImg setImage:[UIImage imageNamed:@"baby"]];
    [headerView addSubview:headerImg];
    self.tableView.tableHeaderView = headerView;
    self.headerImg = headerImg;
    
}

#pragma mark - 懒加载数据
- (NSMutableArray *)items {
    if (_items == nil) {
        // 加载plist数据
        NSArray *itemArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leftItem.plist" ofType:nil]];
        _items = [NSMutableArray array];
        for (NSDictionary *dict in itemArray) {
            [_items addObject:[HMLeftItem leftItemWithDict:dict]];
        }
    }
    return _items;
}

- (UILabel *)cacheLabel{
    if (_cacheLabel == nil) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 155, 8, 50, 30)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = [UIColor whiteColor];
        _cacheLabel = label;
    }
    return _cacheLabel;
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 声明重用标示
    static NSString *ID = @"item";
    // 获得cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        // 设置cell的背景颜色为透明色
        cell.backgroundColor = [UIColor clearColor];
        // 设置textLabel的字体颜色
        cell.textLabel.textColor = [UIColor whiteColor];
        
        // 设置cell选中背景view
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor colorWithRed:101/255.0f green:101/255.0f blue:101/255.0f alpha:0.5];
        cell.selectedBackgroundView = selectedView;
    }
    // 根据indexPath获得模型
    HMLeftItem *item = self.items[indexPath.row];
    // 设置 Cell...
    if ([item.title isEqual:@"清空缓存"]) {
        self.cacheLabel.text = [self calculateCache];
        [cell.contentView addSubview:self.cacheLabel];
    }
    cell.imageView.image = [UIImage imageNamed:item.icon];
    cell.textLabel.text  =item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 点击效果
    HMLeftItem *item = self.items[indexPath.row];
    if ([item.title isEqual:@"清空缓存"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"清除" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
            [self alertConfirm];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        [alert addAction:cancel];
        [self showDetailViewController:alert sender:nil];
    }else if([item.title isEqual:@"Poppy钱包"]){
        //回到主控制器的方法有问题，所以使用关闭效果
        [[HMDrawerViewController sharedDrawer] closeLeftMenuWithDuration:0.25];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushWallet" object:self userInfo:nil];
    }else if ([item.title isEqual:@"我的消息"]){
        //回到主控制器的方法有问题，所以使用关闭效果
        [[HMDrawerViewController sharedDrawer] closeLeftMenuWithDuration:0.25];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushChatView" object:self userInfo:nil];
    }
}

//清除缓存
-(void)alertConfirm{
    [self cleanCaches:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
    [self cleanCaches:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject];
    [self cleanCaches:NSTemporaryDirectory()];
    [self reload];
}

#pragma mark - 清空缓存
// 计算目录大小
- (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return 0;
}
// 根据路径删除文件
- (void)cleanCaches:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

- (void)reload{
    [self.tableView reloadData];
}

//计算缓存，返回字符串
- (NSString *) calculateCache{
    CGFloat size = [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] - 0.000259 + [self folderSizeAtPath:NSTemporaryDirectory()];
    NSString *message = size > 1 ? [NSString stringWithFormat:@"%.2fM", size] : [NSString stringWithFormat:@"%.2fK", size * 1024.0];
    return message;
}



@end
