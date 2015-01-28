#import "Player.h"

// System
#import <AVFoundation/AVFoundation.h>

// Clappr
#import "PlayerView.h"
#import "FullscreenViewController.h"


@interface Player () <UIGestureRecognizerDelegate>
{
    BOOL mediaControlIsHidden;
    BOOL shouldUpdate;
    UIView *innerContainer;
    UIView *parentView;
    __weak UIViewController *parentController;
    FullscreenViewController *fullscreenController;
    NSTimer *mediaControlTimer;


}

@property (nonatomic, weak) IBOutlet UIView *controlsOverlay;
@property (nonatomic, weak) IBOutlet UIView *scrubber;
@property (nonatomic, weak) IBOutlet UIView *scrubberCenter;
@property (nonatomic, weak) IBOutlet UIView *seekBarContainer;
@property (nonatomic, weak) IBOutlet UIView *mediaControl;

@property (nonatomic, weak) IBOutlet UIButton *fullscreenButton;

@property (nonatomic, weak) IBOutlet UIView *positionBar;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *positionBarConstraint;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *seekBarTap;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *seekBarDrag;

@end

@implementation Player

#pragma mark - Ctors

- (instancetype)init
{
    return [self initWithOptions:nil];
}

- (instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        mediaControlIsHidden = NO;
        shouldUpdate = YES;
        fullscreenController = [[FullscreenViewController alloc] init];

    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _player = [AVPlayer playerWithURL: [NSURL URLWithString: @"https://github.com/globocom/clappr-website/raw/gh-pages/highline.mp4"]];
    [_playerView setPlayer: _player];

    [self setupControlsOverlay];
    [self setupScrubber];

//    __weak Player *weakSelf = self;
//
//    [_player addPeriodicTimeObserverForInterval: CMTimeMake(1, 3) queue: nil usingBlock: ^(CMTime time) {
//        [weakSelf.currentTimeLabel setText:[weakSelf getFormattedTime: time]];
//        [weakSelf syncScrubber];
//    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoEnded)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
}

- (void)startMediaControlTimer
{
    [self stopMediaControlTimer];
    mediaControlTimer = [NSTimer scheduledTimerWithTimeInterval:2.5f
                                                         target:self
                                                       selector:@selector(hideMediaControl)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)stopMediaControlTimer
{
    if (mediaControlTimer && [mediaControlTimer isValid]) {
        [mediaControlTimer invalidate];
        mediaControlTimer = nil;
    }
}

- (void)videoEnded
{
    [_player seekToTime: kCMTimeZero];
    [self syncScrubber];
//    _playPause.selected = !_playPause.selected;
}

- (void)setupControlsOverlay
{
    // This creates a gradient using the C API, so we don't need to update the gradient layer
    // when rotating the device
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat components[8] = {
        0, 0, 0, 0,
        0, 0, 0, 0.9
    };
    CGGradientRef result = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsBeginImageContext(_controlsOverlay.frame.size);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), result, CGPointMake(0, 0), CGPointMake(0, _controlsOverlay.frame.size.height), 0);
    UIImage* gradientTexture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _controlsOverlay.backgroundColor = [UIColor colorWithPatternImage:gradientTexture];
}



- (void)setupScrubber
{
    _scrubber.layer.cornerRadius = _scrubber.frame.size.width / 2;
    _scrubberCenter.layer.cornerRadius = _scrubberCenter.frame.size.width / 2;
    _scrubber.layer.borderColor = [UIColor colorWithRed:192 / 255.0f
                                                  green:192 / 255.0f
                                                   blue:192 / 255.0f
                                                  alpha:1.0f].CGColor;
}

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container
{
    parentView = container;
    parentController = controller;
    [controller addChildViewController:self];
    [container addSubview:self.view];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": self.view}]];

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": self.view}]];

    [container setNeedsLayout];

    innerContainer = [[UIView alloc] initWithFrame:self.view.superview.bounds];
    innerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [innerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(250)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views: @{@"view": innerContainer}]];
    [innerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[view(320)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"view": innerContainer}]];
}

- (void)syncScrubber
{
    float current = ((float) CMTimeGetSeconds(_player.currentTime)) / CMTimeGetSeconds(_player.currentItem.asset.duration);
    if (isfinite(current) && current >= 0 && shouldUpdate) {
        [self updatePositionBarConstraints: current * _seekBarContainer.frame.size.width];
    }
}

- (void)showMediaControl
{
    [UIView animateWithDuration:0.3f animations: ^{
        _mediaControl.alpha = 1.0f;
    }];
    [self startMediaControlTimer];
    mediaControlIsHidden = false;
}

- (void)hideMediaControl
{
    if (shouldUpdate) {
        [UIView animateWithDuration:0.3f animations: ^{
            _mediaControl.alpha = 0.0f;
        }];
        mediaControlIsHidden = true;
    }
}

- (void)updatePositionBarConstraints:(CGFloat)width
{
    _positionBarConstraint.constant = width;
    [_seekBarContainer setNeedsLayout];
}

- (void)scaleUpScrubber
{
    [UIView animateWithDuration:0.3f animations: ^{
        _scrubber.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        _scrubber.layer.borderWidth = 1.0f / 1.5f;
        _scrubberCenter.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }];
}

- (void)undoScrubberTransform
{
    [UIView animateWithDuration:0.3f animations: ^{
        _scrubber.layer.borderWidth = 0.0f;
        _scrubber.transform = CGAffineTransformIdentity;
        _scrubberCenter.transform = CGAffineTransformIdentity;
    }];
}

- (CMTime)positionToTime:(CGPoint)position
{
    return CMTimeMakeWithSeconds(position.x * CMTimeGetSeconds(_player.currentItem.asset.duration) / _seekBarContainer.frame.size.width, 1);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf scaleUpScrubber];
    });
    return YES;
}

- (IBAction)toggleMediaControl:(UITapGestureRecognizer *)sender
{
    if (mediaControlIsHidden) {
        [self showMediaControl];
    } else {
        [self hideMediaControl];
    }
}

//- (IBAction)togglePlayPause:(id)sender {
//    if (_playPause.selected) {
//        [_player pause];
//        [self stopMediaControlTimer];
//    } else {
//        [_player play];
//        [self startMediaControlTimer];
//    }
//    _playPause.selected = !_playPause.selected;
//}

- (IBAction)dragScrubber:(UIPanGestureRecognizer *) sender
{
    shouldUpdate = NO;
    CGPoint translation = [sender locationInView: _seekBarContainer];
    [self updatePositionBarConstraints: translation.x];
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self undoScrubberTransform];
        [_player seekToTime: [self positionToTime: translation]];
        shouldUpdate = YES;
        [self startMediaControlTimer];
    }
}

- (IBAction)seekTo:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [sender locationInView: _seekBarContainer];
        [_player seekToTime: [self positionToTime: position]];
        [self updatePositionBarConstraints: position.x];
        [self undoScrubberTransform];
    }
}

- (void)enterFullscreen
{
    [self removeFromParentViewController];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    window.rootViewController = fullscreenController;
    [window addSubview:fullscreenController.view];

    [fullscreenController.view addSubview:innerContainer];

    [innerContainer addSubview:self.view];

    [innerContainer removeConstraints: innerContainer.constraints];
    [innerContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"|[view]|" options:0 metrics:0 views:@{@"view": self.view}]];
    [innerContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]|" options:0 metrics:0 views:@{@"view": self.view}]];

    [fullscreenController.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"|[view]|"
                                                                                       options:0
                                                                                       metrics:0
                                                                                         views:@{@"view": innerContainer}]];
    [fullscreenController.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]|"
                                                                                       options:0
                                                                                       metrics:0
                                                                                         views:@{@"view": innerContainer}]];
    [UIView animateWithDuration:.2 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        [fullscreenController.view layoutIfNeeded];
    } completion:nil];
}

- (IBAction)cancelMediaControlHide:(UILongPressGestureRecognizer *)sender
{
    [self stopMediaControlTimer];
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self undoScrubberTransform];
        [self startMediaControlTimer];
    }
}

- (void)exitFullscreen
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = parentController;
    [parentController addChildViewController: self];

    [parentView addSubview: self.view];
    [innerContainer removeFromSuperview];
    [fullscreenController.view removeFromSuperview];
    [UIView animateWithDuration:.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        [parentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"|[view]|" options:0 metrics:0 views:@{@"view": self.view}]];
        [parentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]|" options:0 metrics:0 views:@{@"view": self.view}]];
        [parentView layoutIfNeeded];
    } completion:nil];
}

- (IBAction)toggleFullscreen:(id)sender {
    if (_fullscreenButton.selected) {
        [self exitFullscreen];
    } else {
        [self enterFullscreen];
    }
    _fullscreenButton.selected = !_fullscreenButton.selected;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                            duration:duration];
    [self syncScrubber];
}

@end
