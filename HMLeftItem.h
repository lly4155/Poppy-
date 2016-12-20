//
//  HMLeftItem.h
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMLeftItem : NSObject
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  要跳转的目标控制器
 */
@property (nonatomic, copy) NSString *destVc;

+(instancetype)leftItemWithDict:(NSDictionary *)dict;

@end
