//
//  HMNewsCell.h
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class HMNews;
@interface HMNewsCell : MGSwipeTableCell

@property(nonatomic,strong)HMNews *news;

@end
