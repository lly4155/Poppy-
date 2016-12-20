//
//  LyPhotoView.h
//  Poppy网易
//
//  Created by LLy on 16/8/5.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyPhotoView : UIView

@property (nonatomic,assign) NSInteger index;
-(instancetype)initWithURLStrs:(NSArray *)URLStrs;
@end
