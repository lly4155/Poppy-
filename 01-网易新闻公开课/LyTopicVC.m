//
//  LyTopicVC.m
//  Poppy网易
//
//  Created by LLy on 16/7/17.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "LyTopicVC.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "Scan_VC.h"
#import "QRCodeGenerator.h"
#import "ViewController2.h"
#import "CZAdditions.h"

@interface LyTopicVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, weak)UITextField *creat;
@end

@implementation LyTopicVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    //扫描结果文本框
    UITextField *text = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 30)];
    text.borderStyle = UITextBorderStyleRoundedRect;
    text.placeholder = @"扫描结果";
    text.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:text];
    self.result = text;
    //生产二维码输入文本框
    UITextField *creat = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-40, 30)];
    creat.borderStyle = UITextBorderStyleRoundedRect;
    creat.placeholder = @"请输入想要生成的二维码信息";
    creat.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:creat];
    self.creat = creat;
    //生成二维码按钮
    UIButton *creatBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 200, 100, 40)];
    [creatBtn setTitle:@"Creat" forState:UIControlStateNormal];
    creatBtn.backgroundColor = [UIColor colorWithRed:213/255.0 green:24/255.0 blue:37/255.0 alpha:0.8];
    creatBtn.layer.cornerRadius = 15;
    creatBtn.tintColor = [UIColor whiteColor];
    [creatBtn addTarget:self action:@selector(creat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:creatBtn];
}

//生成二维码
- (void)creat:(id)sender{
    //有值才生成 ?很奇怪，留个坑，返回的是一个空对象
    [self.view endEditing:YES];
    if (![self.creat.text isEqualToString:@""]) {
        ViewController2 *VC2 = [[ViewController2 alloc]initWithImg:[self encodeQRImageWithContent:self.creat.text size:CGSizeMake(300, 300)] andText:self.creat.text];
        [self.navigationController pushViewController:VC2 animated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入生成的信息" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
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
            onColor = [UIColor cz_randomColor];
            offColor = [UIColor cz_randomColor];
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

- (IBAction)openQR:(id)sender {
    Scan_VC *vc=[[Scan_VC alloc]initWithSuperVC:self];
    [self.navigationController pushViewController:vc animated:YES];
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

-(void)viewDidAppear:(BOOL)animated{
    [self setTabBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self setTabBarHidden:YES];
    [self.view endEditing:YES];//收起键盘
}

@end
