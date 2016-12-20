//
//  HMNetworkTool.h
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void(^FinishedBlock)(id obj,NSError *error);

@interface HMNetworkTool : AFHTTPSessionManager

+ (instancetype)sharedHMNetworkTool;

- (void)getObjectWithURLString:(NSString *)URLString params:(id)params finishedBlock:(FinishedBlock)finishedBlock;

@end
