//
//  MHPlayerControlBar.m
//  MHPlayer_test
//
//  Created by MH on 2017/5/9.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import "MHPlayerControlBar.h"

#define P_HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

@interface MHPlayerControlBar ()
@property(nonatomic,strong) UIButton * playStopBtn;//开始暂停按钮
@property(nonatomic,strong) UIButton * fullScrBtn;//全屏按钮
@property(nonatomic,strong) UILabel * curentTimeLab;//当前时间 lab
@property(nonatomic,strong) UILabel * totleTimeLab;//视频总时间 lab
@property(nonatomic,assign) NSInteger videoTotleTime;//视频总时长 time
@property (nonatomic,strong) UISlider * videoSlider;//播放进度滑竿
@property(nonatomic,strong) UIProgressView * progressView;//缓冲进度条

@end

@implementation MHPlayerControlBar

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.playStopBtn];
        [self addSubview:self.fullScrBtn];
        [self addSubview:self.curentTimeLab];
        [self addSubview:self.totleTimeLab];
        
        [self addSubview:self.progressView];
        [self addSubview:self.videoSlider];
        
        [self maskSubViewLayout];
    }
    return self;
}
#pragma mark - 添加子控件约束
-(void)maskSubViewLayout
{
    self.playStopBtn.sd_layout.leftSpaceToView(self, 0).topEqualToView(self).bottomEqualToView(self).widthEqualToHeight();
    
    self.fullScrBtn.sd_layout.rightSpaceToView(self, 0).topEqualToView(self).bottomEqualToView(self).widthEqualToHeight();
    
    self.curentTimeLab.sd_resetLayout.leftSpaceToView(self.playStopBtn, 0).topEqualToView(self).bottomEqualToView(self).widthIs(40);
    
    self.totleTimeLab.sd_resetLayout.rightSpaceToView(self.fullScrBtn, 0).topEqualToView(self).bottomEqualToView(self).widthIs(40);
    
    self.videoSlider.sd_resetLayout.leftSpaceToView(self.curentTimeLab, 10-5.5).rightSpaceToView(self.totleTimeLab, 10-5.5).bottomEqualToView(self).topEqualToView(self);
    self.progressView.sd_resetLayout.leftSpaceToView(self.curentTimeLab, 10).rightSpaceToView(self.totleTimeLab, 10).centerYEqualToView(self).heightIs(5);
}
#pragma mark - 开始 暂停
-(void)playOrStop
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlBarPlayItemClick)]) {
        [self.delegate controlBarPlayItemClick];
    }
}
#pragma mark - set isPlaying
-(void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    if (isPlaying) {
        [self.playStopBtn setImage:[UIImage imageNamed:@"暂停_small"] forState:0];
    }else {
        [self.playStopBtn setImage:[UIImage imageNamed:@"播放-_small"] forState:0];
    }
}
#pragma mark - slider滑动中事件
-(void)sliderValueChanged:(UISlider *)paramSender{
    NSInteger curentTime = self.videoTotleTime * paramSender.value;
    self.curentTimeLab.text = [self changeTime:curentTime];
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlBarVideoSliderSlidering)]) {
        [self.delegate controlBarVideoSliderSlidering];
    }
}
#pragma mark - slider滑动结束事件
-(void)SliderTouchEnded:(UISlider *)paramSender {
    if ([paramSender isEqual:self.videoSlider]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(controlBarVideoSliderValueChange:)]) {
            [self.delegate controlBarVideoSliderValueChange:paramSender.value];
        }
    }
}
#pragma mark - 设置缓冲进度
-(void)setProcessValue:(CGFloat)processValue
{
    self.progressView.progress = processValue;
}
#pragma mark - control重播按钮点击 设置时间
-(void)rePlayReSetTime
{
    [self.videoSlider setValue:0.0 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlBarVideoSliderValueChange:)]) {
        [self.delegate controlBarVideoSliderValueChange:self.videoSlider.value];
    }
}
#pragma mark - 设置时间 滑块
-(void)setCurentTime:(NSInteger)curentTime totleTime:(NSInteger)totleTime
{
    self.videoTotleTime = totleTime;
    self.curentTimeLab.text = [self changeTime:curentTime];
    self.totleTimeLab.text = [self changeTime:totleTime];
    CGFloat value = (CGFloat)curentTime / totleTime;
    [self.videoSlider setValue:value animated:YES];
}
#pragma mark - 将秒数转换成 xx:xx:xx
-(NSString *)changeTime:(NSInteger)time
{
    NSString * changedTime = @"00:00";
    if (time > 0) {
        changedTime = @"";
        NSInteger shi = 0;
        NSInteger fen = time / 60;
        NSInteger miao = time % 60;
        if (fen > 60) {
            shi = fen / 60;
            fen = fen % 60;
        }
        
        if (shi > 0) {
            changedTime = [NSString stringWithFormat:@"%02ld:",(long)shi];
        }
        changedTime = [NSString stringWithFormat:@"%@%02ld:%02ld",changedTime,fen,miao];
    }
    return changedTime;
}
-(void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        [self.fullScrBtn setImage:[UIImage imageNamed:@"smalscreen"] forState:0];
    }else {
        [self.fullScrBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:0];
    }
}
#pragma mark - 全屏按钮点击
-(void)fullSrcItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlBarFullSrcItemClick)]) {
        [self.delegate controlBarFullSrcItemClick];
    }
}
#pragma mark - get
-(UISlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc] init];
        _videoSlider.value = 0.0;//开始默认值
        _videoSlider.minimumTrackTintColor = P_HexRGBAlpha(0x34aeff, 1);
        _videoSlider.maximumTrackTintColor = P_HexRGBAlpha(0x999999, 1);
        [_videoSlider setThumbImage:[UIImage imageNamed:@"play_yuan"] forState:UIControlStateNormal];
        [_videoSlider setThumbImage:[UIImage imageNamed:@"play_yuan"] forState:UIControlStateNormal];
        // slider滑动中事件
        [_videoSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(SliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    return _videoSlider;
}
-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor clearColor];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progress = 0.0;
    }
    return _progressView;
}
-(UILabel *)curentTimeLab
{
    if (!_curentTimeLab) {
        _curentTimeLab = [[UILabel alloc] init];
        _curentTimeLab.textColor = [UIColor whiteColor];
        _curentTimeLab.font = [UIFont systemFontOfSize:12];
        _curentTimeLab.textAlignment = NSTextAlignmentCenter;
        _curentTimeLab.text = @"00:00";
    }
    return _curentTimeLab;
}
-(UILabel *)totleTimeLab
{
    if (!_totleTimeLab) {
        _totleTimeLab = [[UILabel alloc] init];
        _totleTimeLab.textColor = [UIColor whiteColor];
        _totleTimeLab.font = [UIFont systemFontOfSize:12];
        _totleTimeLab.textAlignment = NSTextAlignmentCenter;
        _totleTimeLab.text = @"00:00";
    }
    return _totleTimeLab;
}
-(UIButton *)playStopBtn
{
    if (!_playStopBtn) {
        _playStopBtn = [UIButton buttonWithType:0];
        [_playStopBtn setImage:[UIImage imageNamed:@"播放-_small"] forState:0];
        [_playStopBtn addTarget:self action:@selector(playOrStop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playStopBtn;
}
-(UIButton *)fullScrBtn
{
    if (!_fullScrBtn) {
        _fullScrBtn = [UIButton buttonWithType:0];
        [_fullScrBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:0];
        [_fullScrBtn addTarget:self action:@selector(fullSrcItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScrBtn;
}
@end
