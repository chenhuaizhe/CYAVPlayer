//
//  PlayerViewController.m
//  CCYYAVPlayer
//
//  Created by CY on 15/11/26.
//  Copyright © 2015年 chenyuan. All rights reserved.
//

#import "PlayerViewController.h"
#import "VideoView.h"
#import "ControlView.h"

@interface PlayerViewController ()
@property (nonatomic,strong) AVPlayer *videoPlayer;            //播放器
@property (nonatomic,strong) VideoView *videoView;            //播放器视频显示层
@property (strong) AVPlayerItem *item;                   //视频资源层

@property (nonatomic,strong) ControlView *controlView;           //控件视图

@property (nonatomic,assign) CGRect originFrame;             //原始frame（竖屏）
@property (nonatomic,assign) BOOL isFullscreen;              //是否横屏
@property (nonatomic,assign) UIInterfaceOrientation currentOrientation;     //当前屏幕方向

@property (nonatomic,strong) id timeObserver;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    
}

-(void)dealloc
{
    [self removeTimeObserver];
    [self.item removeObserver:self forKeyPath:@"status"];
    [_videoPlayer cancelPendingPrerolls];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_videoPlayer pause];
    [_controlView setIsPlaying:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [super viewWillDisappear:animated];
}


#pragma mark - UIViewController的方法，用来设置支持的屏幕方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

//是否支持自动旋转
-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)initUI{
    self.view.backgroundColor = [UIColor blackColor];
    
}

- (void)initData{
    [self setup];
    //监测屏幕的状态是否发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

}


- (void)setup{
    //设置开始时候的frame为全屏的frame
    self.originFrame = self.view.frame;
    
    //添加控件视图
    if(!_controlView)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ControlView class]) owner:nil options:nil];
        if(nibArray.count > 0)
        {
            ControlView *view = nibArray[0];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:view];
            
            self.controlView = view;
            //添加约束
            NSDictionary *paramDic = @{@"viewHeight":@(70.0f)};
            NSArray *view_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
            NSArray *view_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(viewHeight)]|" options:0 metrics:paramDic views:NSDictionaryOfVariableBindings(view)];
            [self.view addConstraints:view_H];
            [self.view addConstraints:view_V];
        }
        else
        {
            NSAssert(0, @"there was no xib named ...");
        }
        
        __weak PlayerViewController *weakSelf = self;
        [_controlView showWithClickHandle:^(NSInteger tag) {
            switch (tag) {
                case 1:
                {//播放或暂停
                    if(weakSelf.videoPlayer.rate > 0)
                    {
                        weakSelf.controlView.isPlaying = NO;
                        [weakSelf.videoPlayer pause];
                    }
                    else
                    {
                        weakSelf.controlView.isPlaying = YES;
                        [weakSelf.videoPlayer play];
                    }
                }
                    break;
                case 2:
                {//全屏
                    if(!weakSelf.isFullscreen)
                    {
                        [weakSelf turnToLeft];
                    }
                    else
                    {
                        [weakSelf turnToPortraint];
                    }
                }
                    break;
                default:
                    break;
            }
        } slideHandle:^(CGFloat interval,BOOL isFinished) {
            if(isFinished)
            {
                //滑块拖动停止
                CMTime time = CMTimeMakeWithSeconds(interval, weakSelf.videoPlayer.currentItem.duration.timescale);
                [weakSelf.videoPlayer seekToTime:time completionHandler:^(BOOL finished) {
                    [weakSelf.videoPlayer play];
                    weakSelf.controlView.isPlaying = YES;
                }];
            }
            else
            {
                if(weakSelf.videoPlayer.rate > 0)
                {
                    weakSelf.controlView.isPlaying = NO;
                    [weakSelf.videoPlayer pause];
                }
            }
        }];
    }
    
    //添加屏幕单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    
}

-(void)setVideoURLString:(NSString *)videoUrl
{
    if(_videoURLString != videoUrl)
    {
        _videoURLString = videoUrl;
        if(_videoURLString == nil)
        {
            return;
        }
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:_videoURLString] options:nil];
        NSArray *requestedKeys = @[@"playable"];
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
            dispatch_async(dispatch_get_main_queue(),^{
                [self prepareToPlayAsset:asset withKeys:requestedKeys];
            });
        }];
    }
}



- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable)
    {
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    if (self.item)
    {
        [self.item removeObserver:self forKeyPath:@"status"];
    }
    
    self.item = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.item addObserver:self
                forKeyPath:@"status"
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                   context:nil];
    
    if (!self.videoPlayer)
    {
        self.videoPlayer = [AVPlayer playerWithPlayerItem:self.item];
    }
    
    if (self.videoPlayer.currentItem != self.item)
    {
        [self.videoPlayer replaceCurrentItemWithPlayerItem:self.item];
    }
    
    [self removeTimeObserver];
    
    __weak PlayerViewController *weakSelf = self;
    self.timeObserver = [_videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat currentTime = CMTimeGetSeconds(time);
        
        [weakSelf.controlView setSlideValue:currentTime / weakSelf.controlView.videoDuration];
    }];
    
    if(!_videoView)
    {
        self.videoView = [[VideoView alloc]initWithFrame:self.view.bounds];
        _videoView.translatesAutoresizingMaskIntoConstraints = NO;
        _videoView.player = _videoPlayer;
        [_videoView setFillMode:AVLayerVideoGravityResizeAspect];
        [self.view insertSubview:_videoView belowSubview:_controlView];
        
        NSArray *view_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView)];
        NSArray *view_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView)];
        [self.view addConstraints:view_H];
        [self.view addConstraints:view_V];
    }
    [self.view sendSubviewToBack:_videoView];
    
    [_videoPlayer play];
}


-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                        message:[error localizedFailureReason]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//    [alertView show];
}


#pragma mark - 移除观察者
-(void)removeTimeObserver
{
    if (_timeObserver)
    {
        [self.videoPlayer removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}



#pragma mark - 点击屏幕，隐藏控制面板
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.view];
    if(!CGRectContainsPoint(_controlView.frame, point))
    {
        [_controlView setHidden:!_controlView.isHidden];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Notification

//屏幕方向改变
-(void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation; //获取当前设备方向
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    //设备方向改变之后，把_currentOrientation的值改为当前方向，并执行相关动作
    if(interfaceOrientation != _currentOrientation)
    {
        _currentOrientation = interfaceOrientation;
        
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
            {
                [self turnToPortraint];
            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                [self turnToPortraint];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                [self turnToLeft];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                [self turnToRight];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark － 改变视频视图方向

-(void)turnToPortraint
{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = _originFrame;
    }completion:^(BOOL finished) {
        self.isFullscreen = NO;
    }];
}

-(void)turnToLeft
{
    CGRect frect = [self getLandscapeFrame]; //获取横屏时候的frame
    
    //横屏旋转的时候 需要先置为初始状态，否则会出现位置偏移的情况
    if(_isFullscreen)
    {
        self.view.transform = CGAffineTransformIdentity;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.view.frame = frect;
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }completion:^(BOOL finished) {
        self.isFullscreen = YES;
    }];
}

-(void)turnToRight
{
    CGRect frect = [self getLandscapeFrame];
    
    if(_isFullscreen)
    {
        self.view.transform = CGAffineTransformIdentity;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.view.frame = frect;
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }completion:^(BOOL finished) {
        self.isFullscreen = YES;
    }];
}

#pragma mark - 横屏时的frame
-(CGRect)getLandscapeFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGRect frect = CGRectZero;
    frect.origin.x = (screenSize.width - screenSize.height) / 2.0f;
    frect.origin.y = (screenSize.height - screenSize.width) / 2.0f;
    frect.size.width = screenSize.height;
    frect.size.height = screenSize.width;
    
    return frect;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                [_controlView setIsPlaying:YES];
                [_controlView setIsControlEnable:YES];
                
                //只有在播放状态才能获取视频时间长度
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                NSTimeInterval duration = CMTimeGetSeconds(playerItem.asset.duration);
                _controlView.videoDuration = duration;
            }
                break;
            case AVPlayerStatusFailed:
            {
                [_controlView setIsPlaying:NO];
                
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
            case AVPlayerStatusUnknown:
            {
                [_controlView setIsPlaying:NO];
            }
                break;
            default:
                break;
        }
    }
}

@end
