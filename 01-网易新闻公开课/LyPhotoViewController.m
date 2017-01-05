//
//  LyPhotoViewController.m
//  Poppy网易
//
//  Created by LLy on 16/8/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyPhotoViewController.h"
#import "LyPhotoView.h"
#import "LyReplyViewController.h"
#import "LyNewsViewController.h"
#import "HMDrawerViewController.h"

@interface LyPhotoViewController ()
@property (weak, nonatomic) UIView *contentV;
@property (weak, nonatomic) UILabel *setname;
@property (weak, nonatomic) UILabel *pageNum;
@property (weak, nonatomic) UILabel *content;
@property (nonatomic, strong) NSMutableArray *senderAPI;//接收photoID
@property (nonatomic, strong) NSMutableArray *desc;
@property (nonatomic , strong) LyPhotoView *PhotoView;
@property (nonatomic , copy) NSString *commenturl;
@property( nonatomic , assign) NSInteger page;
@property (nonatomic , readonly) CGRect originFrame;
@property (nonatomic, assign) BOOL flag;
@end

@implementation LyPhotoViewController

-(instancetype)initWithURLStrs:(NSString *)url reply:(NSNumber *)reply{
    if (self = [super init]) {
        self.senderAPI = [[NSMutableArray alloc]init];
        [self.senderAPI addObject:url];
        [self.senderAPI addObject:reply];
        self.flag = YES;
        [self loadDate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //监听下一张图片滚动结束事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextPhoto) name:@"nextConent" object:nil];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.flag != YES ) {
        [self loadDate];
    }
}

- (void) loadDate{
    NSString *photoID = self.senderAPI[0];
    //取出关键字
    NSArray *parameters = [[photoID substringFromIndex:4] componentsSeparatedByString:@"|"];
    //1、URL
    NSString *photoUrl = [NSString stringWithFormat:@"http://c.m.163.com/photo/api/set/%@/%@.json",[parameters firstObject],[parameters lastObject]];
    
    NSURL *loadData = [NSURL URLWithString:photoUrl];
    
    //2、建立请求
    NSURLRequest *request = [NSURLRequest requestWithURL:loadData];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
    
    if (dic) {
        NSArray *photos = [dic objectForKey:@"photos"];
        self.commenturl = [dic objectForKey:@"commenturl"];
        //加上图片器
        NSMutableArray *photosURL = [[NSMutableArray alloc]init];
        //新闻内容
        NSMutableArray *desc = [[NSMutableArray alloc]init];
        
        for (int i=0;i<photos.count;i++) {
            NSString *url = [[photos objectAtIndex:i]objectForKey:@"imgurl"];
            [photosURL addObject:url];
            NSString *descUrl = [[photos objectAtIndex:i]objectForKey:@"note"];
            [desc addObject:descUrl];
        }
        _desc =  desc;
        
        LyPhotoView *photoView = [[LyPhotoView alloc] initWithURLStrs:photosURL];
        photoView.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:photoView];
        self.PhotoView = photoView;
        
        
        //加载back按钮
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 40, 40)];
        backBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_back"]];
        [backBtn addTarget:self action:@selector(turnBack:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:backBtn];
        
        //加载评论按钮
        NSInteger anInteger = [_senderAPI[1] integerValue];
        NSString *displayCount;
        if (anInteger > 10000) {
            displayCount = [NSString stringWithFormat:@"%.1ld万跟帖",anInteger/10000];
        }else if (anInteger == 0)
            displayCount = @"0跟帖";
        else if(anInteger == -1)
            displayCount = @"查看跟帖";
        else{
            displayCount = [NSString stringWithFormat:@"%.0ld跟帖",(long)anInteger];
        }
        
        UIButton *reply = [[UIButton alloc]init];
        [reply setTitle:displayCount forState:UIControlStateNormal];
        [reply sizeToFit];
        reply.titleLabel.font = [UIFont systemFontOfSize:13.0];
        reply.titleLabel.textAlignment = NSTextAlignmentCenter;
        float width = reply.frame.size.width;
        reply.frame = CGRectMake(self.view.frame.size.width - width - 25, 30, width + 13, 40);
        [reply addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
        [reply setBackgroundImage:[UIImage imageNamed:@"contentview_commentbacky"] forState:UIControlStateNormal];
        [self.view addSubview:reply];
        
        //初始化加载内容
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(20, 40 , self.view.frame.size.width - 30, 22)];
        content.numberOfLines = 0;
        content.textColor = [UIColor whiteColor];
        self.content = content;
        
        //标题和页数
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20, 10 , self.view.frame.size.width - 80, 22)];
        title.text = [dic valueForKey:@"setname"];
        title.numberOfLines = 1;
        title.font = [UIFont systemFontOfSize:20];
        title.textColor = [UIColor whiteColor];
        self.setname = title;
        
        UILabel *pageNum = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, 10, 60, 22)];
        pageNum.textColor = [UIColor whiteColor];
        self.pageNum = pageNum;
        
        
        //初始化内容View
        UIView *contentV = [[UIView alloc]init];
        if (content.frame.size.height > 60) {
            contentV.frame = CGRectMake(0, self.view.frame.size.height - 110, self.view.frame.size.width, content.frame.size.height + 50);
        }else{
            contentV.frame = CGRectMake(0, self.view.frame.size.height - content.frame.size.height - 50, self.view.frame.size.width, content.frame.size.height + 50);
        }
        _originFrame = contentV.frame;//保存初始值
        contentV.layer.cornerRadius = 15;
        contentV.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.5];
        [self.view addSubview:contentV];
        [contentV addSubview:content];
        [contentV addSubview:title];
        [contentV addSubview:pageNum];
        self.contentV = contentV;
        [self nextPhoto];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"网络出错" message:@"数据加载失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//触摸内容View的事件
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (touch.view == self.contentV) {
        CGPoint current = [touch locationInView:self.view];
        CGPoint previous = [touch previousLocationInView:self.view];
        CGFloat offsetY = current.y - previous.y;
        [UIView animateWithDuration:0.5 animations:^{
        if (offsetY < 0) {
                self.contentV.frame = CGRectMake(0, self.view.frame.size.height - self.content.frame.size.height - 50, self.view.frame.size.width, _content.frame.size.height + 50);
        }
            else{
                self.contentV.frame = _originFrame;
            }
        }];
    }
}

- (void) nextPhoto{
    //获得滚动的页数，然后赋值刷新
    _page = self.PhotoView.index;
    self.content.text = [_desc objectAtIndex:_page];
    _content.frame = CGRectMake(20, 40 , self.view.frame.size.width - 30, 22);
    [_content sizeToFit];
    //页数
    NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)self.page+1];
    NSString *currentPage = [NSString stringWithFormat:@"%@/%lu",pageStr,(unsigned long)_desc.count];
    NSMutableAttributedString *count = [[NSMutableAttributedString alloc]initWithString:currentPage];
    [count addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, pageStr.length)];
    _pageNum.attributedText = count;
    
     [UIView animateWithDuration:0.5 animations:^{
    if (_content.frame.size.height > 60) {
        _contentV.frame = CGRectMake(0, self.view.frame.size.height - 110, self.view.frame.size.width, _content.frame.size.height + 50);
    }else{
        _contentV.frame = CGRectMake(0, self.view.frame.size.height - _content.frame.size.height - 50, self.view.frame.size.width, _content.frame.size.height + 50);
    }
         }];
    _originFrame = _contentV.frame;
}

- (void) turnBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) reply{
    LyReplyViewController *replyVc = [[LyReplyViewController alloc]initWithUrl:_commenturl];
    [self.navigationController pushViewController:replyVc animated:YES];
}

//隐藏导航条
- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}


//获得屏幕图像
- (UIImage *)imageFromView: (UIView *) theView
{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


@end
