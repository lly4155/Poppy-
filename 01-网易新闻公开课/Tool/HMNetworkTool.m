//
//  HMNetworkTool.m
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/9.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "HMNetworkTool.h"

@implementation HMNetworkTool


static HMNetworkTool *_instance;

+ (instancetype)sharedHMNetworkTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://c.m.163.com/nc/"]];
        
        _instance.responseSerializer.acceptableContentTypes = [_instance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    
    return _instance;
}

- (void)getObjectWithURLString:(NSString *)URLString params:(id)params finishedBlock:(FinishedBlock)finishedBlock{
    [self GET:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (finishedBlock) {
            finishedBlock(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (finishedBlock) {
            finishedBlock(nil,error);
            NSLog(@"%@",error);
        }
    }];
}


@end
