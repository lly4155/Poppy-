//
//  LyNewsViewController.h
//  Poppy网易
//
//  Created by LLy on 16/8/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyNewsViewController : UIViewController
@property (nonatomic,copy) NSString *url;
-(instancetype)initWithURLStrs:(NSString *)url;
@end
