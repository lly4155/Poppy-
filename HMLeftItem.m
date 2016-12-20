//
//  HMLeftItem.m
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import "HMLeftItem.h"

@implementation HMLeftItem

+ (instancetype)leftItemWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}
@end
