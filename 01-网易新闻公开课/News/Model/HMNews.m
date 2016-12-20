//
//  HMNews.m
//  01-网易新闻公开课
//
//  Created by 黄伟 on 16/3/10.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "HMNews.h"
#import "HMNetworkTool.h"

@implementation HMNews

+ (instancetype)newsWithDict:(NSDictionary *)dict{
    id obj = [[self alloc] init];
    
    //KVC
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+ (void)newsListWithURLString:(NSString *)URLString completeBlock:(CompleteBlock)completeBlock{
    [[HMNetworkTool sharedHMNetworkTool] getObjectWithURLString:URLString params:nil finishedBlock:^(id obj, NSError *error) {
        //1.有错误
        if (error!=nil) {
            NSLog(@"%@",error.localizedDescription);
            
            return;
        }
        
        //2.没有错误，开始解析
        NSDictionary *dict = (NSDictionary *)obj;
        
        //3.获取字典的key值
        NSString *keyName = dict.keyEnumerator.nextObject;
        
        //4.通过字典的key值,来获取字典数组
        NSMutableArray *dictArray = dict[keyName];
        
        NSMutableArray *newsList = [NSMutableArray arrayWithCapacity:dictArray.count];
        
        //5.遍历字典,转成对应的模型
        for (NSDictionary *dict in dictArray) {
            HMNews *news = [HMNews newsWithDict:dict];
            [newsList addObject:news];
        }
        //6.回调block
        if (completeBlock) {
            completeBlock(newsList);
        }
    }];
}

//- (NSString *)description{
//    return [NSString stringWithFormat:@"%@---%@",_title,_digest];
//}

@end
