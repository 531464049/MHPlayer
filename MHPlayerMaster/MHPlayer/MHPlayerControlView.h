//
//  MHPlayerControlView.h
//  MHPlayer_test
//
//  Created by MH on 2017/5/9.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHPlayerDefine.h"
#import "MHPlayerControlBar.h"
/*
 刚创建 只显示加载菊花
 加载结束 显示controlbar
 
 点击空白区域 全部显示（除菊花）
 再次点击 全部隐藏
 
 当网络不好时 显示加载菊花 不显示开始按钮 显示bar  ？？？？？
 */

@protocol MHPlayerControlDelegate <NSObject>

/**
 通知播放器开始播放、暂停播放
 @param play 开始/暂停
 */
-(void)playerControl_playOrStop:(BOOL)play;

/**
 通知播放器是否全屏
 */
-(void)playerControl_fullSrcNoti;

/**
 通知播放器播放进度改变
 @param value 改变进度
 */
-(void)playerControl_VideoSliderChange:(CGFloat)value;

@end

@interface MHPlayerControlView : UIView

@property(nonatomic,weak)id <MHPlayerControlDelegate> delegate;
@property(nonatomic,strong)UIButton * fullScrBackBtn;       //全屏播放时 返回按钮
@property(nonatomic,strong)MHPlayerControlBar * controlBar;       //底部控制条
@property(nonatomic,assign)BOOL isFullScr;           //当前播放 是否是全屏状态


/*加载菊花开始动画*/
-(void)startAnimation;

/*加载菊花结束动画*/
-(void)stopAnimation;


/**
 playerlayer播放/暂停 由播放器调用，更新control，回调播放器
 @param play 是否播放
 */
-(void)playerLayerPlayStop:(BOOL)play;


/**
 播放结束的通知 由player调用，更新control，重播按钮显示
 @param finished 是否播放完成
 */
-(void)playerIsPlayFinished:(BOOL)finished;
@end
