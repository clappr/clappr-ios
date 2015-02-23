#import "CLPPlayback.h"

// Clappr
#import "UIView+NSLayoutConstraints.h"
#import "CLPAVFoundationPlayback.h"

NSString *const CLPPlaybackEventProgress = @"clappr:playback:progress";
NSString *const CLPPlaybackEventTimeUpdated = @"clappr:playback:time_updated";
NSString *const CLPPlaybackEventReady = @"clappr:playback:ready";
NSString *const CLPPlaybackEventBuffering = @"clappr:playback:buffering";
NSString *const CLPPlaybackEventBufferFull = @"clappr:playback:buffer_full";
NSString *const CLPPlaybackEventSettingsUdpdated = @"clappr:playback:settings_updated";
NSString *const CLPPlaybackEventLoadedMetadata = @"clappr:playback:loaded_metadata";
NSString *const CLPPlaybackEventHighDefinitionUpdate = @"clappr:playback:hd_updated";
NSString *const CLPPlaybackEventBitRate = @"clappr:playback:bitrate";
NSString *const CLPPlaybackEventStateChanged = @"clappr:playback:state_changed";
NSString *const CLPPlaybackEventDVRStateChanged = @"clappr:playback:dvr_state_changed";
NSString *const CLPPlaybackEventMediaControlDisabled = @"clappr:playback:media_control_disabled";
NSString *const CLPPlaybackEventMediaControlEnabled = @"clappr:playback:media_control_enabled";
NSString *const CLPPlaybackEventEnded = @"clappr:playback:ended";
NSString *const CLPPlaybackEventPlay = @"clappr:playback:play";
NSString *const CLPPlaybackEventPause = @"clappr:playback:pause";
NSString *const CLPPlaybackEventError = @"clappr:playback:error";

@implementation CLPPlayback

#pragma mark - Ctors

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithURL: instead"
                                 userInfo:nil];
}

- (instancetype)playbackForURL:(NSURL *)url
{
    return [[CLPAVFoundationPlayback alloc] initWithURL:url];
}

#pragma mark - Controls

- (void)play
{
}

- (void)pause
{
}

- (void)stop
{
}

- (void)seekTo:(NSTimeInterval)timeInterval
{
}

+ (BOOL)canPlayURL:(NSURL *)url
{
    return NO;
}

- (void)destroy
{
    [self.view removeFromSuperview];
    [self stopListening];
}

#pragma mark - Accessors

- (NSUInteger)duration
{
    return 0;
}

- (BOOL)isPlaying
{
    return NO;
}

@end
