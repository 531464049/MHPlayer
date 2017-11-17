//
//  MHPlayerControlView.m
//  MHPlayer_test
//
//  Created by MH on 2017/5/9.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import "MHPlayerControlView.h"


@interface MHPlayerControlView ()<UIGestureRecognizerDelegate,MHPlayerConBarDelegate>
@property(nonatomic,strong)UIActivityIndicatorView * activity;       //加载菊花
@property(nonatomic,strong)UIButton * playBtn;              //播放or暂停 按钮
@property(nonatomic,strong)UIView * rePlayView;             //播放完 重播view

@property(nonatomic,assign)BOOL isControlShowing;            //播放控制子控件是否显示
@property(nonatomic,assign)BOOL isPlaying;                //是否在播放
@property(nonatomic,assign)BOOL isPlayFinished;             //是否播放完成

@property (nonatomic, strong) NSTimer * controlTimer;//控制按钮显示/隐藏 定时器
@end

@implementation MHPlayerControlView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.rePlayView];
        [self addSubview:self.playBtn];
        [self addSubview:self.activity];
        [self addSubview:self.controlBar];
        [self addSubview:self.fullScrBackBtn];
        
        //添加子控件约束
        [self makeSubViewLayout];
        
        
        //添加单击事件
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
        
        self.isControlShowing = NO;
        self.isPlaying = YES;
        self.controlBar.isPlaying = self.isPlaying;
        self.controlBar.isFullScreen = NO;
        self.isFullScr = NO;
        self.isPlayFinished = NO;
        
        [self setupTimer];
    }
    return self;
}
#pragma mark - 添加子控件约束
-(void)makeSubViewLayout
{
    self.rePlayView.sd_layout.centerXEqualToView(self).centerYEqualToView(self);
    self.playBtn.sd_layout.centerXEqualToView(self).centerYEqualToView(self).widthIs(57).heightEqualToWidth();
    self.activity.sd_layout.centerYEqualToView(self).centerXEqualToView(self);
    self.controlBar.sd_layout.leftEqualToView(self).bottomEqualToView(self).rightEqualToView(self).heightIs(40);
    self.fullScrBackBtn.sd_layout.leftSpaceToView(self, Width(20)).topSpaceToView(self, Width(21)).widthIs(40).heightEqualToWidth();
}
#pragma mark - 播放-暂停按钮点击
-(void)playOrStop
{
    if (self.isPlaying) {//在播放
        [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:0];
    }else{//已暂停
        [_playBtn setImage:[UIImage imageNamed:@"暂停"] forState:0];
    }
    [self allControlShow];
    self.isPlaying = !self.isPlaying;
    self.controlBar.isPlaying = self.isPlaying;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControl_playOrStop:)]) {
        [self.delegate playerControl_playOrStop:self.isPlaying];
    }
    [self setupTimer];
}
#pragma mark - 重播 点击
-(void)rePlayItemClick
{
    [self.controlBar rePlayReSetTime];
}
#pragma mark - control bar 播放按钮点击代理
-(void)controlBarPlayItemClick
{
    [self playOrStop];
    [self setupTimer];
}
#pragma mark - control bar 全屏按钮点击代理
-(void)controlBarFullSrcItemClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControl_fullSrcNoti)]) {
        [self.delegate playerControl_fullSrcNoti];
    }
    [self setupTimer];
}
#pragma mark - control bar videoSlider状态改变的回调
-(void)controlBarVideoSliderValueChange:(CGFloat)value
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControl_VideoSliderChange:)]) {
        [self.delegate playerControl_VideoSliderChange:value];
    }
    [self setupTimer];
}
#pragma mark - bar slider正在滑动 从新设置定时器
-(void)controlBarVideoSliderSlidering
{
    [self setupTimer];
}
#pragma mark - 全屏状态时 返回按钮 点击
-(void)fullScrBackBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControl_fullSrcNoti)]) {
        [self.delegate playerControl_fullSrcNoti];
    }
    [self setupTimer];
    self.controlBar.isFullScreen = NO;
}
#pragma mark - 播放器传递过来是否是全屏
-(void)setIsFullScr:(BOOL)isFullScr
{
    _isFullScr = isFullScr;
    self.controlBar.isFullScreen = isFullScr;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if (self.isPlayFinished) {
        [self allControlShow];
    }
}
#pragma mark - 开启定时器
- (void)setupTimer
{
    if (self.controlTimer) {
        [self.controlTimer invalidate];
        self.controlTimer = nil;
    }
    if (!self.isPlayFinished) {
        self.controlTimer = [NSTimer scheduledTimerWithTimeInterval:kControllTimerTime target:self selector:@selector(autoHidenControll) userInfo:nil repeats:NO];
    }
}
#pragma mark - 定时器到 自动隐藏控件
-(void)autoHidenControll
{
    self.playBtn.hidden = YES;
    self.controlBar.hidden = YES;
    self.isControlShowing = NO;
    self.fullScrBackBtn.hidden = YES;
    if (_isFullScr) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    if ([self.activity isAnimating]) {
        self.activity.hidden = NO;
    }
}
#pragma mark - 响应单击事件
-(void)singleTap:(UITapGestureRecognizer *)tapGus
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    if (self.isPlayFinished) {//如果播放结束了，点击不再操作显示隐藏效果
        return;
    }
    
    if (self.isControlShowing) {//当前子控件已全部显示 控制全部隐藏
        [self allControlHiden];
    }else{//当前全部隐藏 控制全部显示
        [self allControlShow];
    }
    self.isControlShowing = !self.isControlShowing;
    [self setupTimer];
}
#pragma mark - 控件隐藏
-(void)allControlHiden
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.playBtn.hidden = YES;
    self.controlBar.hidden = YES;
    self.fullScrBackBtn.hidden = YES;
    self.rePlayView.hidden = YES;
    if (_isFullScr) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    if ([self.activity isAnimating]) {
        self.activity.hidden = NO;
    }
}
#pragma mark - 控件显示
-(void)allControlShow
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.playBtn.hidden = NO;
    self.controlBar.hidden = NO;
    self.rePlayView.hidden = YES;
    self.activity.hidden = YES;
    if (_isFullScr) {
        self.fullScrBackBtn.hidden = NO;
    }
    if ([self.activity isAnimating]) {
        self.activity.hidden = NO;
        self.playBtn.hidden = YES;
    }
    if (self.isPlayFinished) {
        self.playBtn.hidden = YES;
        self.activity.hidden = YES;
        self.rePlayView.hidden = NO;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.controlBar]) {
        return NO;
    }
    return YES;
}
#pragma mark - playerlayer播放/暂停 由播放器调用，更新control，回调播放器
-(void)playerLayerPlayStop:(BOOL)play
{
    self.isPlaying = !play;
    [self playOrStop];
}
#pragma mark - 播放结束的通知 由player调用，更新control，重播按钮显示
-(void)playerIsPlayFinished:(BOOL)finished
{
    self.isPlayFinished = finished;
    [self setupTimer];
    [self allControlShow];
}
#pragma mark - 开始加载动画
-(void)startAnimation
{
    //隐藏除菊花外所有子控件
    self.activity.hidden = NO;
    [self.activity startAnimating];
}
#pragma mark - 结束加载动画
-(void)stopAnimation
{
    //加载结束 显示controlbar 其他隐藏
    [self.activity stopAnimating];
    self.activity.hidden = YES;
}
#pragma mark - get
-(UIView *)rePlayView
{
    if (!_rePlayView) {//72*72
        _rePlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width(36), Width(36) + Width(15) + Width(15))];
        _rePlayView.backgroundColor = [UIColor clearColor];
        _rePlayView.hidden = YES;
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width(36), Width(36))];
        img.image = [UIImage imageNamed:@"play_replay"];
        [_rePlayView addSubview:img];
        
        UILabel * lab = [self labTextColor:[UIColor whiteColor] font:FONT(15) left:YES];
        lab.text = @"重播";
        lab.textAlignment = NSTextAlignmentCenter;
        [_rePlayView addSubview:lab];
        lab.sd_layout.leftEqualToView(_rePlayView).bottomEqualToView(_rePlayView).rightEqualToView(_rePlayView).heightIs(Width(15));
        
        UIButton * btn = [UIButton buttonWithType:0];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(rePlayItemClick) forControlEvents:UIControlEventTouchUpInside];
        [_rePlayView addSubview:btn];
        btn.sd_layout.leftEqualToView(_rePlayView).topEqualToView(_rePlayView).rightEqualToView(_rePlayView).bottomEqualToView(_rePlayView);
    }
    return _rePlayView;
}
-(UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activity.hidesWhenStopped = YES;
        _activity.color = [UIColor whiteColor];
        _activity.hidden = YES;
    }
    return _activity;
}
-(UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:0];
        [_playBtn setImage:[UIImage imageNamed:@"暂停"] forState:0];
        _playBtn.hidden = YES;
        [_playBtn addTarget:self action:@selector(playOrStop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
-(UIButton *)fullScrBackBtn
{
    if (!_fullScrBackBtn) {
        _fullScrBackBtn = [UIButton buttonWithType:0];
        [_fullScrBackBtn setImage:[UIImage imageNamed:@"nav_back"] forState:0];
        _fullScrBackBtn.hidden = YES;
        [_fullScrBackBtn addTarget:self action:@selector(fullScrBackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScrBackBtn;
}
-(MHPlayerControlBar *)controlBar
{
    if (!_controlBar) {
        _controlBar = [[MHPlayerControlBar alloc] init];
        _controlBar.hidden = NO;
        _controlBar.delegate = self;
    }
    return _controlBar;
}
-(UILabel *)labTextColor:(UIColor *)textColor font:(UIFont *)font left:(BOOL)left
{
    UILabel * lab = [[UILabel alloc] init];
    lab.textColor = textColor;
    lab.font = font;
    lab.textAlignment = left ? NSTextAlignmentLeft : NSTextAlignmentRight;
    return lab;
}
@end
