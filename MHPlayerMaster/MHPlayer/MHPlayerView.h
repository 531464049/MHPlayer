//
//  MHPlayerView.h
//  MHPlayer_test
//
//  Created by MH on 2017/5/8.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHPlayerDefine.h"

@interface MHPlayerView : UIView

@property (nonatomic, strong) NSURL * videoURL;

+ (instancetype)sharedPlayerView;

-(void)initFrame:(CGRect)frame videoUrl:(NSString *)videoUrl;

-(instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl;



/**开始播放*/
-(void)play;

/**暂停*/
-(void)stop;

/**清除player所有*/
-(void)clearAll;

@end
