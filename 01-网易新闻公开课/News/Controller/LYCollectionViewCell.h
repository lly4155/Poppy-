//
//  LYCollectionViewCell.h
//  Poppy网易
//
//  Created by LLy on 2016/11/4.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYChannelModel;

@interface LYCollectionViewCell : UICollectionViewCell
@property (nonatomic,copy) void(^setTabBarHidden)(BOOL);//tabbar隐藏回调
@property (nonatomic,copy) void(^segueJump)(NSString *,NSString *,NSNumber *);//segue跳转，给VC执行，cell没有该方法
@property (nonatomic,copy) NSString *channelID;
@end
