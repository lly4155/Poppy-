//
//  LoopView.h
//  图片无限轮播
//
//  Created by LLy on 16/5/31.
//  Copyright © 2016年 LLy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopView : UIView 

-(instancetype)initWithURLStrs:(NSArray *)URLStrs titles:(NSArray *)titles url:(NSArray *)url tag:(NSArray *)tag;
- (UIViewController *)viewController;
@end
