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

static NSString *clapprFontName;
static UINib *mediaControlNib;

@interface CLPMediaControl ()

@property (nonatomic, weak, readwrite) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIButton *fullscreenButton;

@end


@implementation CLPMediaControl

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
        self.view = [[mediaControlNib instantiateWithOwner:self options:nil] lastObject];
        self.view.backgroundColor = [UIColor clearColor];
        self.view.accessibilityLabel = @"Media Control";

        [container.view clappr_addSubviewMatchingFrameOfView:self.view];

        _container = container;

        [self bindEventListeners];
        [self setupControls];
        [self addTapGestureToShowOrHideControls];
    }
    return self;
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

    _currentTimeLabel.text = @"00:00";
    _durationLabel.text = @"00:00";

    _fullscreenButton.titleLabel.font = [UIFont fontWithName:clapprFontName size:30.0f];
    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateNormal];
    [_fullscreenButton setTitle:kMediaControlTitleFullscreen forState:UIControlStateSelected];
}

- (void)addTapGestureToShowOrHideControls
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tapGesture];
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
    }
}

- (void)stop
{
    if (!_container.playing)
        return;

    [_container stop];
    [self trigger:CLPMediaControlEventNotPlaying];
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
}

- (void)containerDidEnd
{
    _playPauseButton.selected = NO;
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

@end
