//
//  CLPMediaControl.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/18/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPMediaControl.h"

// System
#import <CoreText/CoreText.h>
#import <AVFoundation/AVFoundation.h>

// Clappr
#import "CLPContainer.h"
#import "CLPPlayback.h"
#import "UIView+NSLayoutConstraints.h"

NSString *const CLPMediaControlEventPlaying = @"clappr:media_control:playing";
NSString *const CLPMediaControlEventNotPlaying = @"clappr:media_control:not_playing";

static NSString *const kMediaControlTitlePlay = @"\ue001";
static NSString *const kMediaControlTitlePause = @"\ue002";
static NSString *const kMediaControlTitleStop = @"\ue003";
static NSString *const kMediaControlTitleVolume = @"\ue004";
static NSString *const kMediaControlTitleMute = @"\ue005";
static NSString *const kMediaControlTitleFullscreen = @"\ue006";
static NSString *const kMediaControlTitleHD = @"\ue007";

static CGFloat const kMediaControlAnimationDuration = 0.3;

static NSString *clapprFontName;

NSTimeInterval CLPAnimationDuration(BOOL animated) {
    return animated ? kMediaControlAnimationDuration : 0.0;
}

@interface CLPMediaControl ()
{
    __weak IBOutlet UIButton *_playPauseButton;

    __weak IBOutlet UILabel *_durationLabel;
    __weak IBOutlet UILabel *_currentTimeLabel;

    __weak IBOutlet UIButton *_fullscreenButton;
}
@end


@implementation CLPMediaControl

#pragma mark - Ctors

+ (void)initialize
{
    if (self == [CLPMediaControl class]) {
        [self loadPlayerFont];
    }
}

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {

        UINib *nib = [UINib nibWithNibName:@"CLPMediaControlView" bundle:nil];
        self.view = [[nib instantiateWithOwner:self options:nil] lastObject];
        self.view.backgroundColor = [UIColor clearColor];

        [container.view clappr_addSubviewMatchingFrameOfView:self.view];

        _container = container;

        [self bindEventListeners];
        [self setupControls];
        [self addTapGestureToShowOrHideControls];

        // AVPlayer
//        [_player addPeriodicTimeObserverForInterval: CMTimeMake(1, 3) queue: nil usingBlock: ^(CMTime time) {
//            [weakSelf.currentTimeLabel setText:[weakSelf getFormattedTime: time]];
//            [weakSelf syncScrubber];
//        }];
    }
    return self;
}

- (void)setupDuration
{
//    [_durationLabel setText:[self getFormattedTime:_player.currentItem.asset.duration]];
}

- (NSString *)getFormattedTime:(CMTime)time
{
    //FIXME: there is a better way to do it, without `+(NSString*) stringWithFormat:`
    NSUInteger totalSeconds = CMTimeGetSeconds(time);
    NSUInteger minutes = floor(totalSeconds % 3600 / 60);
    NSUInteger seconds = floor(totalSeconds % 3600 % 60);
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long) minutes, (unsigned long) seconds];
}

- (void)bindEventListeners
{
    __weak typeof(self) weakSelf = self;
    [self listenTo:_container eventName:CLPContainerEventPlay callback:^(NSDictionary *userInfo) {
        [weakSelf containerDidPlay];
    }];

    [self listenTo:_container eventName:CLPContainerEventPause callback:^(NSDictionary *userInfo) {
        [weakSelf containerDidPause];
    }];
}

- (void)setupControls
{
    _playPauseButton.titleLabel.font = [UIFont fontWithName:clapprFontName size:60.0f];
    [_playPauseButton setTitle:kMediaControlTitlePlay forState:UIControlStateNormal];
    [_playPauseButton setTitle:kMediaControlTitlePause forState:UIControlStateSelected];

    _fullscreenButton.titleLabel.font = [UIFont fontWithName:clapprFontName size:30.0f];

    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateNormal];
    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateSelected];
}

- (void)addTapGestureToShowOrHideControls
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Methods

- (void)play
{
    _playPauseButton.selected = YES;
    [_container play];
    [self trigger:CLPMediaControlEventPlaying];
}

- (void)pause
{
    _playPauseButton.selected = NO;
    [_container pause];
    [self trigger:CLPMediaControlEventNotPlaying];
}

- (IBAction)togglePlay
{
    if ([_container isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)stop
{
    if (!_container.playing)
        return;

    [_container stop];
    [self trigger:CLPMediaControlEventNotPlaying];
}

- (void)show
{
    [self showAnimated:NO];
}

- (void)showAnimated:(BOOL)animated
{
    self.view.alpha = 0.0;
    self.view.hidden = NO;

    [UIView animateWithDuration:CLPAnimationDuration(animated) animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)hide
{
    [self hideAnimated:NO];
}

- (void)hideAnimated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:CLPAnimationDuration(animated) animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        weakSelf.view.hidden = finished;
    }];
}

#pragma mark - Notification handling

- (void)containerDidPlay
{
    [self trigger:CLPMediaControlEventPlaying];
}

- (void)containerDidPause
{
    [self trigger:CLPMediaControlEventNotPlaying];
}

#pragma mark - Private

+ (void)loadPlayerFont
{
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"Player-Regular" ofType:@"ttf"];
    NSData *data = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) data);
    CGFontRef font = CGFontCreateWithDataProvider(provider);

    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);

        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }

    CFRelease(font);
    CFRelease(provider);

    clapprFontName = (NSString *)CFBridgingRelease(CGFontCopyPostScriptName(font));
}

@end
