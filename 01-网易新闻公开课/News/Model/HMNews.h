//
//  HMNews.h
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock)(NSMutableArray *newsList);

@interface HMNews : NSObject

// 标题
@property (nonatomic, copy) NSString *title;
// 摘要
@property (nonatomic, copy) NSString *digest;
// 图片
@property (nonatomic, copy) NSString *imgsrc;
// 跟贴数
@property (nonatomic, assign) NSInteger replyCount;
// 多张配图
@property (nonatomic, strong) NSArray *imgextra;
// 多张配图的照片集编号description
@property (nonatomic, copy) NSString *photosetID;
// 大图标记
@property (nonatomic, assign) BOOL imgType;
//广告
@property (nonatomic, strong) NSArray *ads;
//跳转URL
@property (nonatomic,copy) NSString *url_3w;
@property (nonatomic,copy) NSString *url;

+ (void)newsListWithURLString:(NSString *)URLString completeBlock:(CompleteBlock)completeBlock;

@end
