#import "CLPMediaControl.h"

// System
#import <CoreText/CoreText.h>
#import <AVFoundation/AVFoundation.h>

// Clappr
#import "CLPContainer.h"
#import "CLPPlayback.h"
#import "CLPScrubberView.h"
#import "UIView+NSLayoutConstraints.h"

static NSTimeInterval const kMediaControlAnimationDuration = 0.3;

NSString *const CLPMediaControlEventPlaying = @"clappr:media_control:playing";
NSString *const CLPMediaControlEventNotPlaying = @"clappr:media_control:not_playing";

static NSString *const kMediaControlTitlePlay = @"\ue001";
static NSString *const kMediaControlTitlePause = @"\ue002";
static NSString *const kMediaControlTitleVolume = @"\ue004";
static NSString *const kMediaControlTitleMute = @"\ue005";
static NSString *const kMediaControlTitleFullscreen = @"\ue006";
static NSString *const kMediaControlTitleHD = @"\ue007";

static NSString *clapprFontName;
static UINib *mediaControlNib;

@interface CLPMediaControl ()
{
    __weak IBOutlet NSLayoutConstraint *scrubberLeftConstraint;
    __weak IBOutlet UIView *positionBarView;
    __weak IBOutlet UIView *seekBarView;

    CGFloat scrubberInitialPosition;
    NSTimer *hideControlsTimer;
}

@property (nonatomic, weak, readwrite) IBOutlet UIButton *playPauseButton;

@property (nonatomic, weak, readwrite) IBOutlet UIView *controlsOverlayView;
@property (nonatomic, weak, readwrite) IBOutlet UIView *controlsWrapperView;

@property (nonatomic, weak, readwrite) IBOutlet CLPScrubberView *scrubberView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *currentTimeLabel;

@end


@implementation CLPMediaControl

#pragma mark - Dtor

- (void)dealloc
{
    [hideControlsTimer invalidate];
}

#pragma mark - Ctors

+ (void)initialize
{
    if (self == [CLPMediaControl class]) {
        [self loadPlayerFont];
        mediaControlNib = [UINib nibWithNibName:@"CLPMediaControlView" bundle:nil];
    }
}

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;

        self.view = [[mediaControlNib instantiateWithOwner:self options:nil] lastObject];
        self.view.backgroundColor = [UIColor clearColor];
        [container.view clappr_addSubviewMatchingFrameOfView:self.view];

        [self addAccessibilityLabels];
        [self bindEventListeners];
        [self setupControls];
    }
    return self;
}

- (void)addAccessibilityLabels
{
    self.view.accessibilityLabel = @"media control";
    _playPauseButton.accessibilityLabel = @"play/pause";
    _currentTimeLabel.accessibilityLabel = @"current time";
    _durationLabel.accessibilityLabel = @"duration";
    _scrubberView.accessibilityLabel = @"scrubber";
    seekBarView.accessibilityLabel = @"seek bar";
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

    [self listenTo:_container eventName:CLPContainerEventTimeUpdate callback:^(NSDictionary *userInfo) {
        float position = [userInfo[@"position"] floatValue];
        NSTimeInterval duration = [userInfo[@"duration"] doubleValue];
        [weakSelf containerDidUpdateTimeToPosition:position
                                          duration:duration];
    }];

    [self listenTo:_container eventName:CLPContainerEventReady callback:^(NSDictionary *userInfo) {

        NSUInteger duration = weakSelf.container.playback.duration;
        weakSelf.durationLabel.text = [weakSelf formattedTime:duration];
    }];

    [self listenTo:_container eventName:CLPContainerEventEnded callback:^(NSDictionary *userInfo) {
        [weakSelf containerDidEnd];
    }];
}

- (void)setupControls
{
    _playPauseButton.titleLabel.font = [UIFont fontWithName:clapprFontName size:60.0f];
    [_playPauseButton setTitle:kMediaControlTitlePlay forState:UIControlStateNormal];
    [_playPauseButton setTitle:kMediaControlTitlePause forState:UIControlStateSelected];

    scrubberInitialPosition = scrubberLeftConstraint.constant;

    _fullscreenButton.titleLabel.font = [UIFont fontWithName:clapprFontName size:30.0f];
    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateNormal];
    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateSelected];
}

#pragma mark - Control Actions

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
        hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideAfterStartToPlay) userInfo:nil repeats:NO];
    }
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

- (void)containerDidUpdateTimeToPosition:(float)position
                                duration:(NSTimeInterval)duration
{
    _currentTimeLabel.text = [self formattedTime:position];

    float percentage = duration == 0 ? 0 : position / duration;
    CGFloat delta = CGRectGetWidth(seekBarView.frame) * percentage;

    scrubberLeftConstraint.constant = scrubberInitialPosition + delta;
    [_scrubberView setNeedsLayout];
}

- (void)containerDidEnd
{
    _playPauseButton.selected = NO;
}

#pragma mark - Show / Hide

- (void)hide
{
    [self hideAnimated:NO];
}

- (void)hideAnimated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;

    NSTimeInterval duration = animated ? kMediaControlAnimationDuration : 0.0;
    [UIView animateWithDuration:duration animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        for (UIView *subview in self.view.subviews)
            subview.hidden = YES;

        if (finished)
            weakSelf.controlsHidden = YES;
    }];
}

- (void)show
{
    [self showAnimated:NO];
}

- (void)showAnimated:(BOOL)animated
{
    for (UIView *subview in self.view.subviews) {
        subview.hidden = NO;
    }

    __weak typeof(self) weakSelf = self;

    NSTimeInterval duration = animated ? kMediaControlAnimationDuration : 0.0;
    [UIView animateWithDuration:duration animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        if (finished)
            weakSelf.controlsHidden = NO;
    }];
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

- (NSString *)formattedTime:(NSUInteger)totalSeconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSUInteger oneHour = 1 * 60 * 60;
    if (totalSeconds < oneHour)
        [formatter setDateFormat:@"mm:ss"];
    else
        [formatter setDateFormat:@"HH:mm:ss"];

    return [formatter stringFromDate:date];
}

- (void)hideAfterStartToPlay
{
    if (_container.isPlaying) {
        [self hideAnimated:YES];
    }

    [hideControlsTimer invalidate];
}

@end
