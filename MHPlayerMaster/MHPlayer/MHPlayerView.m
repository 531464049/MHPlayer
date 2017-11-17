//
//  MHPlayerView.m
//  MHPlayer_test
//
//  Created by MH on 2017/5/8.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import "MHPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MHPlayerControlView.h"//播放控制
@interface MHPlayerView ()<MHPlayerControlDelegate>
@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;
@property (nonatomic, strong) id       timeObserve;//播放进度time观察者

@property(nonatomic,strong)MHPlayerControlView * playControl;//播放控制view

@property(nonatomic,assign) BOOL isFullSrc;//是否是全屏状态

@property(nonatomic,strong) UIView * fatherView;//保存横屏前的父view
@property(nonatomic,assign) CGRect oldRect;//保存横屏前 在父view的frame
@property(nonatomic,assign) BOOL firstTimeFullSrc;//第一次点击全屏按钮 为了保存fatherView和oldRect

@property(nonatomic,assign)BOOL isPlaying;//是否在播放
@property(nonatomic,assign)BOOL isBackgroundPause;//是否是退出后台暂停
@end

@implementation MHPlayerView

+ (instancetype)sharedPlayerView {
    static MHPlayerView *playerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[MHPlayerView alloc] init];
    });
    return playerView;
}
-(void)initFrame:(CGRect)frame videoUrl:(NSString *)videoUrl
{
    self.frame = frame;
    NSURL * url = [NSURL URLWithString:videoUrl];
    self.videoURL = url;
}
-(instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        NSURL * url = [NSURL URLWithString:videoUrl];
        self.videoURL = url;
    }
    return self;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    [self clearAll];
    [self configMHPlayer];
}
#pragma mark - 设置player相关参数
-(void)configMHPlayer
{
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.backgroundColor = [UIColor blackColor];
    //此处设置视频填充模式为默认
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放进度计时观察者
    [self addTimeObserve];
    [self addSubview:self.playControl];
    [self.playControl playerLayerPlayStop:NO];
    [self reSetFrames];
    self.isFullSrc = NO;
    self.firstTimeFullSrc = YES;
}
#pragma mark - 开始播放
-(void)play
{
    [self.playControl playerLayerPlayStop:YES];
//    [self.playControl startAnimation];
}
#pragma mark - 暂停
-(void)stop
{
    [self.playControl playerLayerPlayStop:NO];
}
#pragma mark - 重置子控件frame
-(void)reSetFrames
{
    self.playerLayer.frame = self.bounds;
    _playControl.frame = self.bounds;
}
-(MHPlayerControlView *)playControl
{
    if (!_playControl) {
        _playControl = [[MHPlayerControlView alloc] init];
        _playControl.delegate = self;
    }
    return _playControl;
}
#pragma mark - control delegate 播放/暂停
-(void)playerControl_playOrStop:(BOOL)play
{
    if (play) {
        if (self.player) {
            [_player play];
            self.isPlaying = YES;
        }
    }else{
        if (self.player) {
           [_player pause];
            self.isPlaying = NO;
        }
    }
}
#pragma mark - control delegate 全屏按钮点击 通知
-(void)playerControl_fullSrcNoti
{
    if (self.firstTimeFullSrc) {//第一次点击全屏按钮 保存原始父view frame
        self.fatherView = self.superview;
        self.oldRect = self.frame;
        self.firstTimeFullSrc = NO;
    }
    
    if (self.isFullSrc) {//当前播放器是全屏状态 转为非全屏
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
        [self removeFromSuperview];
        [self.fatherView addSubview:self];
        self.frame = self.oldRect;
        [self reSetFrames];
        self.playControl.fullScrBackBtn.hidden = YES;
        self.isFullSrc = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }else{//当前播放器是非全屏状态 转为全屏
        [self removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        self.center = [UIApplication sharedApplication].keyWindow.center;
        [self reSetFrames];
        
        // iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
        // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
        // 给你的播放视频的view视图设置旋转
        self.transform = CGAffineTransformIdentity;
        self.transform = [self getTransformRotationAngle];
        [UIView commitAnimations];
        self.isFullSrc = YES;
        self.playControl.fullScrBackBtn.hidden = NO;
    }
    self.playControl.isFullScr = self.isFullSrc;
}
- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
#pragma mark - control delegate 播放进度改变
-(void)playerControl_VideoSliderChange:(CGFloat)value
{
    if (value < 1.0) {//时间进度小于1，说明拖动的时间不是结束
        [self.playControl playerIsPlayFinished:NO];
    }
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // 视频总时间长度
        CGFloat total= (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * value);
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            [self.playControl playerLayerPlayStop:YES];
        }];
    }
}
#pragma mark - 添加播放进度时间观察
-(void)addTimeObserve
{
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            NSInteger totalTime     = (NSInteger)currentItem.duration.value / currentItem.duration.timescale;
            [weakSelf.playControl.controlBar setCurentTime:currentTime totleTime:totalTime];
        }
    }];
}
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        // app退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                // 添加playerLayer到self.layer
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                
                [self.playControl stopAnimation];
                
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            CGFloat value = timeInterval / totalDuration;
            [self.playControl.controlBar setProcessValue:value];//设置控制条 缓冲进度
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                [self.playControl startAnimation];
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {//// 缓冲区有足够数据可以播放了
            [self.playControl stopAnimation];
        }
    }
}
#pragma mark - 计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 当前视频播放完了
- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self.playControl playerLayerPlayStop:NO];
    [self.playControl playerIsPlayFinished:YES];
}
#pragma mark - app退出到后台
-(void)appDidEnterBackground
{
//    NSLog(@"app退出到后台");
    [self.playControl playerLayerPlayStop:NO];
    if (self.isPlaying) {
//        NSLog(@"自动控制暂停");
        self.isBackgroundPause = YES;
    }
}
#pragma mark - app进入前台
-(void)appDidEnterPlayground
{
//    NSLog(@"app进入前台");
    if (self.isBackgroundPause) {
//        NSLog(@"自动开始播放");
        [self.playControl playerLayerPlayStop:YES];
        self.isBackgroundPause = NO;
    }
}
- (void)dealloc {
    [self clearAll];
}
-(void)clearAll{
    self.playerItem = nil;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除time观察者
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    if (_player) {//暂停
        [_player pause];
    }
    // 移除原来的layer
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    // 替换PlayerItem为nil
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player = nil;
    }
    //清除playControl
    if (self.playControl) {
        [self.playControl removeFromSuperview];
        self.playControl = nil;
    }
    [self removeFromSuperview];
}
@end
