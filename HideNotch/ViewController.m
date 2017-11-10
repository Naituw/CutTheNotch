//
//  ViewController.m
//  HideNotch
//
//  Created by 吴天 on 2017/11/10.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

// set to 1 when you want to create your own launch.mov
// use QuickTimePlayer - File - New Video Recording
#define RECORD_MODE 0

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, strong) UIImageView * statusBarView;
@property (nonatomic, strong) UIImageView * notchView;
@property (nonatomic, assign) BOOL showsNotch;

@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@property (nonatomic, strong) UIControl * startPlayButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"HideNotch Demo";
    
#if RECORD_MODE
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#else
    [UIApplication sharedApplication].keyWindow.transform = CGAffineTransformMakeRotation(M_PI);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#endif
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#if !RECORD_MODE
    [self.view.window addSubview:self.statusBarView];
    [self.view.window.layer addSublayer:self.playerLayer];
    [self.view.window addSubview:self.notchView];
    [self.view.window addSubview:self.startPlayButton];
    [self.view setUserInteractionEnabled:NO];
    
    _showsNotch = YES;
    
    [self.view setNeedsLayout];
#endif
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIWindow * window = self.view.window;
    CGPoint center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));
    _button.center = [self.view convertPoint:center fromView:window];
    
    CGSize notchSize = _notchView.image.size;
    _notchView.frame = CGRectMake((self.view.bounds.size.width - notchSize.width) / 2, 0, notchSize.width, notchSize.height);
    CGSize statusBarSize = _statusBarView.image.size;
    _statusBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, statusBarSize.height);
    _playerLayer.frame = CGRectInset(self.view.bounds, 0, -1.0/3);
    _startPlayButton.frame = self.view.bounds;
}

- (UIImageView *)notchView
{
    if (!_notchView) {
        _notchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notch.png"]];
    }
    return _notchView;
}

- (UIImageView *)statusBarView
{
    if (!_statusBarView) {
        _statusBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusbar.png"]];
    }
    return _statusBarView;
}

- (AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        AVPlayer * player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"launch" ofType:@"mov"]]];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (UIControl *)startPlayButton
{
    if (!_startPlayButton) {
        _startPlayButton = [[UIControl alloc] initWithFrame:CGRectZero];
        [_startPlayButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [_startPlayButton setBackgroundColor:[UIColor clearColor]];
    }
    return _startPlayButton;
}

- (void)setShowsNotch:(BOOL)showsNotch
{
    if (_showsNotch != showsNotch) {
        _showsNotch = showsNotch;
        
        [_button setTitle:showsNotch ? @"Hide" : @"Show" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _notchView.alpha = showsNotch ? 1.0 : 0.0;
        } completion:NULL];
    }
}

- (IBAction)toggleNotch:(id)sender
{
    self.showsNotch = !self.showsNotch;
}

- (void)tap:(id)sender
{
    [_startPlayButton removeFromSuperview];
    
    [_playerLayer.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerLayer.player.currentItem];
}

- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    [_playerLayer removeFromSuperlayer];
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

// Didn't find a way to completly hide homeIndicator
// Use pan instead of tap when demosrating, so the indicator won't appear
- (BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

#if !RECORD_MODE
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#endif

@end

@interface UINavigationController (Orientation)

@end

@implementation UINavigationController (Orientation)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
