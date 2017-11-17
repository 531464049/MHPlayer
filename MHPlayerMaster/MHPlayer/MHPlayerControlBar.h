//
//  MHPlayerControlBar.h
//  MHPlayer_test
//
//  Created by MH on 2017/5/9.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHPlayerDefine.h"
#import "UIView+SDAutoLayout.h"

@protocol MHPlayerConBarDelegate <NSObject>


/**
 control bar 播放按钮点击代理
 */
-(void)controlBarPlayItemClick;

/**
 control bar 全屏按钮点击代理
 */
-(void)controlBarFullSrcItemClick;

/**
 control bar videoSlider状态改变回调
 @param value value
 */
-(void)controlBarVideoSliderValueChange:(CGFloat)value;


/**
 control bar videoslider正在滑动
 */
-(void)controlBarVideoSliderSlidering;
@end

@interface MHPlayerControlBar : UIView

@property(nonatomic,weak) id <MHPlayerConBarDelegate> delegate;
@property(nonatomic,assign) BOOL isPlaying;//是否在播放
@property(nonatomic,assign) BOOL isFullScreen;//当前是否是全屏

/**
 当前时间、总时间
 @param curentTime 当前时间
 @param totleTime 视频总时间
 */
-(void)setCurentTime:(NSInteger)curentTime totleTime:(NSInteger)totleTime;

/**
 设置缓冲进度条进度
 @param processValue 缓冲进度
 */
-(void)setProcessValue:(CGFloat)processValue;


/**
 control重播按钮点击 设置时间
 */
-(void)rePlayReSetTime;
@end
