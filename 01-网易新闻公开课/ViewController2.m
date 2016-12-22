//
//  ViewController2.m
//  仿支付宝
//
//  Created by 张国兵 on 15/12/10.
//  Copyright © 2015年 zhangguobing. All rights reserved.
//

#import "ViewController2.h"
#import "UIView+SDExtension.h"
#import "HyPopMenuView.h"
#import "CommonMarco.h"
#import "WXApi.h"
#import "popMenvTopView.h"
#import "CZAdditions.h"
#import <ChameleonFramework/Chameleon.h>

@interface ViewController2 ()<HyPopMenuViewDelegate,WXApiDelegate>
@property (nonatomic, strong)UIImage *creatImg;
@property (nonatomic, weak)UIImageView *myCode;
@property (nonatomic, strong)HyPopMenuView *menu;
@property (nonatomic, strong)popMenvTopView *topView;
@property (nonatomic, strong)NSString *creatStr;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreMenu:) name:@"moreMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareMenu:) name:@"shareMenu" object:nil];
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:238/255.0 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"weather_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
    UIImageView *myCode = [[UIImageView alloc]init];
    if (self.creatImg) {
        myCode.image = self.creatImg;
        myCode.frame = CGRectMake(0, 0, 300,300);
        //中间加一个小头像
        UIImageView *littleImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 66, 66)];
        littleImg.image = [UIImage imageNamed:@"baby1"];
        littleImg.center = CGPointMake(myCode.sd_width/2, myCode.sd_height/2);
        //自适应
        [littleImg setContentMode:UIViewContentModeScaleAspectFill];
        littleImg.clipsToBounds = YES;
        [myCode addSubview:littleImg];
        //添加换颜色按钮
        UIButton *changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
        changeBtn.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 120);
        [changeBtn setTitle:@"Change Color" forState:UIControlStateNormal];
        changeBtn.backgroundColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
        changeBtn.layer.cornerRadius = 15;
        changeBtn.tintColor = [UIColor whiteColor];
        [changeBtn addTarget:self action:@selector(pressedEvent:) forControlEvents:UIControlEventTouchDown];
        [changeBtn addTarget:self action:@selector(ChangeColor:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.view addSubview:changeBtn];
    }else{
        myCode.image = [UIImage imageNamed:@"myCode"];
        myCode.frame = CGRectMake(0, 0, self.view.sd_width,(self.view.sd_width / 674.0 ) * 896);
    }
    //图片大小 674 X 896
    myCode.center = CGPointMake(self.view.sd_width/2, self.view.sd_height/2);
//    [myCode setContentMode:UIViewContentModeScaleAspectFill];
//    myCode.clipsToBounds = YES;
    [self.view addSubview:myCode];
    self.myCode = myCode;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] style:UIBarButtonItemStylePlain target:self action:@selector(disMiss)];
    //解决系统边缘右滑失效问题
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    //分享菜单,分享功能的具体实现在抽屉控制器中。。
    _menu = [HyPopMenuView sharedPopMenuManager];
    [self setShareDataSource];
    _menu.flag = NO;
    _menu.delegate = self;
    _menu.popMenuSpeed = 8.0f;
    _menu.automaticIdentificationColor = TRUE;
    _menu.animationType = HyPopMenuViewAnimationTypeCenter;
    popMenvTopView* topView = [popMenvTopView popMenvTopView];
    topView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), 92);
    _menu.topView = topView;
    
}

//按钮的按下事件 按钮缩小
- (void)pressedEvent:(UIButton *)btn
{
    [UIView animateWithDuration:0.2 animations:^{
        btn.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }];
}
-(void)ChangeColor:(UIButton *)btn{
    [UIView animateWithDuration:0.15 animations:^{
        btn.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        //执行动作响应
        if (self.creatImg) {
            self.myCode.image  = [self encodeQRImageWithContent:self.creatStr size:CGSizeMake(300, 300)];
        }
    }];
}

- (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
        
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        
        UIColor *onColor;
        UIColor *offColor;
        do {
//            onColor = [UIColor cz_randomColor];
//            offColor = [UIColor cz_randomColor];
            onColor = [UIColor colorWithRandomFlatColorExcludingColorsInArray:@[FlatWhite]];
            offColor = [UIColor colorWithRandomFlatColorExcludingColorsInArray:@[FlatBlack, FlatBlackDark, FlatGray, FlatGrayDark, FlatWhiteDark]];
        } while (onColor==offColor);
        
        
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该功能只支持8.0后的系统" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    return codeImage;
}

-(void)setShareDataSource{
    PopMenuModel* model = [PopMenuModel
                           allocPopMenuModelWithImageNameString:@"moment"
                           AtTitleString:@"朋友圈"
                           AtTextColor:[UIColor grayColor]
                           AtTransitionType:PopMenuTransitionTypeCustomizeApi
                           AtTransitionRenderingColor:nil];
    
    PopMenuModel* model1 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"wechat"
                            AtTitleString:@"微信"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model2 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"qq"
                            AtTitleString:@"QQ"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model3 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"qzone"
                            AtTitleString:@"QQ空间"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model4 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"webo"
                            AtTitleString:@"微博"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model5 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"tabbar_compose_more"
                            AtTitleString:@"更多"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    self.menu.dataSource = @[ model, model1, model2, model3, model4, model5 ];
}

-(void)setMoreDataSource{
    PopMenuModel* model = [PopMenuModel
                           allocPopMenuModelWithImageNameString:@"tabbar_compose_idea"
                           AtTitleString:@"文字/头条"
                           AtTextColor:[UIColor grayColor]
                           AtTransitionType:PopMenuTransitionTypeCustomizeApi
                           AtTransitionRenderingColor:nil];
    
    PopMenuModel* model1 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"tabbar_compose_photo"
                            AtTitleString:@"相册/视频"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model2 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"tabbar_compose_camera"
                            AtTitleString:@"拍摄/短视频"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model3 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"tabbar_compose_lbs"
                            AtTitleString:@"签到"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model4 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"tabbar_compose_review"
                            AtTitleString:@"点评"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model5 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"back"
                            AtTitleString:@"返回"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    self.menu.dataSource = @[ model, model1, model2, model3, model4, model5 ];
}

-(void)shareMenu:(id)sender{
    [self setShareDataSource];
    self.menu.flag = NO;
    self.menu.animationType = HyPopMenuViewAnimationTypeCenter;
}

-(void)moreMenu:(id)sender{
    [self setMoreDataSource];
    self.menu.flag = YES;
    self.menu.animationType = HyPopMenuViewAnimationTypeLeftAndRight;
}

-(void)share:(id)sender{
    _menu.backgroundType = HyPopMenuViewBackgroundTypeLightBlur;
    [_menu openMenu];
}

-(void)disMiss{
    [self.navigationController popViewControllerAnimated:YES];
}

//隐藏导航条
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //变透明
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
//    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - 代理回调
/**
 *  处理来自微信的请求
 *
 *  @param resp 响应体。根据 errCode 作出对应处理。
 */
- (void)onResp:(BaseResp *)resp
{
    NSString *message;
    if(resp.errCode == 0) {
        message = @"分享成功";
    }else{
        message = @"分享失败";
    }
    showAlert(message);
}

-(id)initWithImg:(UIImage *)myImg andText:(NSString *)myStr{
    self = [super init];
    _creatImg = myImg;
    _creatStr = myStr;
    return self;
}


@end
