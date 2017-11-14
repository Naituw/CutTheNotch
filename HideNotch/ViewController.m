//
//  ViewController.m
//  HideNotch
//
//  Created by 吴天 on 2017/11/10.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "ViewController.h"
#import "Preferences.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, strong) UIImageView * statusBarView;
@property (nonatomic, strong) UIImageView * notchView;
@property (nonatomic, assign) BOOL showsNotch;

@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@property (nonatomic, strong) UIControl * startPlayButton;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Cut The Notch";
    
    if ([Preferences recordModeEnabled] || [Preferences deviceNotCapable]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    self.button.layer.cornerRadius = 8.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![Preferences recordModeEnabled]) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        
        if (![Preferences deviceNotCapable]) {
            [window addSubview:self.statusBarView];
            [window.layer addSublayer:self.playerLayer];
        }
        [window addSubview:self.notchView];
        
        if (![Preferences deviceNotCapable]) {
            [window addSubview:self.startPlayButton];
            [self.view setUserInteractionEnabled:NO];
        }
        
        _showsNotch = YES;
        
        [self.view setNeedsLayout];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_statusBarView removeFromSuperview];
    [_playerLayer removeFromSuperlayer];
    [_notchView removeFromSuperview];
    [_startPlayButton removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    UIWindow * window = self.view.window;
    CGPoint center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));
    _button.center = [self.view convertPoint:center fromView:window];
    
    if (_panGesture.state != UIGestureRecognizerStateChanged) {
        _notchView.frame = [self notchDefaultFrame];
    }
    CGSize statusBarSize = _statusBarView.image.size;
    _statusBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, statusBarSize.height);
    _playerLayer.frame = CGRectInset(self.view.bounds, 0, -1.0/3);
    
    CGRect startPlayButtonFrame = self.view.bounds;
    startPlayButtonFrame.size.height -= 60;
    _startPlayButton.frame = startPlayButtonFrame;
    
    [CATransaction commit];
}

- (CGRect)notchDefaultFrame
{
    CGSize notchSize = _notchView.image.size;
    return CGRectMake((self.view.bounds.size.width - notchSize.width) / 2, _showsNotch ? 0 : -notchSize.height, notchSize.width, notchSize.height);
}

- (UIImageView *)notchView
{
    if (!_notchView) {
        _notchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notch.png"]];
        _notchView.userInteractionEnabled = YES;
        _notchView.layer.anchorPoint = CGPointMake(0.5, 0);
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        _panGesture.delegate = self;
        
        [_notchView addGestureRecognizer:_panGesture];
    }
    return _notchView;
}

- (UIImageView *)statusBarView
{
    if (!_statusBarView) {
        _statusBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationbar.png"]];
    }
    return _statusBarView;
}

- (AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        NSURL * url = _videoURL ? : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"launch" ofType:@"mov"]];
        AVPlayer * player = [AVPlayer playerWithURL:url];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
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
        
        [UIView animateWithDuration:0.16 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _notchView.frame = [self notchDefaultFrame];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [_panGesture translationInView:_notchView];
    if (ABS(translation.x) > ABS(translation.y)) {
        return NO;
    }
    if (translation.y < 0) {
        return NO;
    }
    return YES;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat notchHeight = _notchView.image.size.height;
            CGFloat targetHeight = notchHeight + [gesture translationInView:self.view].y / 2;
            _notchView.transform = CGAffineTransformMakeScale(1, targetHeight / notchHeight);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _notchView.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }
            break;
        default:
            break;
    }
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}

- (BOOL)prefersStatusBarHidden
{
    if ([Preferences recordModeEnabled]) {
        return NO;
    } else {
        return YES;
    }
}

@end

@interface UIViewController (Orientation)

@end

@implementation UIViewController (Orientation)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([Preferences recordModeEnabled] || [Preferences deviceNotCapable]) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

@end

@interface UINavigationController (Orientation)

@end

@implementation UINavigationController (Orientation)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
