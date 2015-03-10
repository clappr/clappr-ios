#import "CLPContainer.h"

#import "CLPPlayback.h"
#import "CLPUIContainerPlugin.h"
#import "UIView+NSLayoutConstraints.h"

NSString *const CLPContainerEventPlaybackStateChanged = @"clappr:container:playback_state_changed";
NSString *const CLPContainerEventPlaybackStateDVRStateChanged = @"clappr:container:playback_dvr_state_changed";
NSString *const CLPContainerEventBitRate = @"clappr:container:bit_rate";
NSString *const CLPContainerEventStatsReport = @"clappr:container:stats_report";
NSString *const CLPContainerEventDestroyed = @"clappr:container:destroyed";
NSString *const CLPContainerEventReady = @"clappr:container:ready";
NSString *const CLPContainerEventError = @"clappr:container:error";
NSString *const CLPContainerEventLoadedMetadata = @"clappr:container:loaded_metadata";
NSString *const CLPContainerEventTimeUpdate = @"clappr:container:time_update";
NSString *const CLPContainerEventProgress = @"clappr:container:progress";
NSString *const CLPContainerEventPlay = @"clappr:container:play";
NSString *const CLPContainerEventStop = @"clappr:container:stop";
NSString *const CLPContainerEventPause = @"clappr:container:pause";
NSString *const CLPContainerEventEnded = @"clappr:container:ended";
NSString *const CLPContainerEventTap = @"clappr:container:tap";
NSString *const CLPContainerEventSeek = @"clappr:container:seek";
NSString *const CLPContainerEventVolume = @"clappr:container:volume";
NSString *const CLPContainerEventFullscreen = @"clappr:container:fullscreen";
NSString *const CLPContainerEventBuffering = @"clappr:container:buffering";
NSString *const CLPContainerEventBufferFull = @"clappr:container:buffer_full";
NSString *const CLPContainerEventSettingsUpdated = @"clappr:container:settings_updated";
NSString *const CLPContainerEventHighDefinitionUpdated = @"clappr:container:hd_updated";
NSString *const CLPContainerEventMediaControlDisabled = @"clappr:container:media_control_disabled";
NSString *const CLPContainerEventMediaControlEnabled = @"clappr:container:media_control_enabled";

@interface CLPContainer ()
{
    NSMutableSet *p_plugins;
}
@end


@implementation CLPContainer

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithPlayback: instead"
                                 userInfo:nil];
}

- (instancetype)initWithPlayback:(CLPPlayback *)playback
{
    self = [super init];
    if (self) {
        self.playback = playback;
        [self.view clappr_addSubviewMatchingFrameOfView:_playback.view];
        p_plugins = [@[] mutableCopy];
    }

    return self;
}

- (void)bindEventListeners
{
    __weak typeof(self) weakSelf = self;
    [self listenTo:_playback
         eventName:CLPPlaybackEventProgress
          callback:^(NSDictionary *userInfo) {

        float startPosition = [userInfo[@"start_position"] floatValue];
        float endPosition = [userInfo[@"end_position"] floatValue];
        NSTimeInterval duration = [userInfo[@"duration"] doubleValue];
        [weakSelf progressWithStartPosition:startPosition endPosition:endPosition duration:duration];
    }];
    
    [self listenTo:_playback
         eventName:CLPPlaybackEventTimeUpdated
          callback:^(NSDictionary *userInfo) {

        float position = [userInfo[@"position"] floatValue];
        NSTimeInterval duration = [userInfo[@"duration"] doubleValue];
        [weakSelf timeUpdatedWithPosition:position duration:duration];
    }];

    [self listenTo:_playback
         eventName:CLPPlaybackEventLoadedMetadata
          callback:^(NSDictionary *userInfo) {

        NSTimeInterval duration = [userInfo[@"duration"] doubleValue];
        [weakSelf loadedMetadataWithDuration:duration];
    }];

    [self listenTo:_playback
         eventName:CLPPlaybackEventDVRStateChanged
          callback:^(NSDictionary *userInfo) {

        BOOL dvrInUse = [userInfo[@"dvr_in_use"] boolValue];
        [weakSelf dvrStateChanged:dvrInUse];
    }];

    [self listenTo:_playback
         eventName:CLPPlaybackEventError
          callback:^(NSDictionary *userInfo) {

        NSError *errorObj = userInfo[@"error"];
        [weakSelf error:errorObj];
    }];

    [self listenTo:_playback
         eventName:CLPPlaybackEventBitRate
          callback:^(NSDictionary *userInfo) {

        float bitRate = [userInfo[@"bit_rate"] floatValue];
        [weakSelf updateBitrate:bitRate];
    }];

    NSDictionary *eventsToForward = @{
        CLPPlaybackEventReady: ^{ [weakSelf ready]; },
        CLPPlaybackEventBuffering: ^{ [weakSelf buffering]; },
        CLPPlaybackEventBufferFull: ^{ [weakSelf bufferFull]; },
        CLPPlaybackEventSettingsUdpdated: ^{ [weakSelf settingsUpdated]; },
        CLPPlaybackEventHighDefinitionUpdate: ^{ [weakSelf highDefinitionUpdated]; },
        CLPPlaybackEventStateChanged: ^{ [weakSelf stateChanged]; },
        CLPPlaybackEventMediaControlDisabled: ^{ [weakSelf disableMediaControl]; },
        CLPPlaybackEventMediaControlEnabled: ^{ [weakSelf enableMediaControl]; },
        CLPPlaybackEventEnded: ^{ [weakSelf ended]; },
        CLPPlaybackEventPlay: ^{ [weakSelf play]; },
        CLPPlaybackEventPause: ^{ [weakSelf pause]; }
    };

    [eventsToForward enumerateKeysAndObjectsUsingBlock:^(NSString *eventName, void(^executionBlock)(), BOOL *stop) {
        [weakSelf listenTo:weakSelf.playback
                 eventName:eventName
                  callback:^(NSDictionary *userInfo) { executionBlock(); }];
    }];
}

#pragma mark - Event Callbacks

- (void)progressWithStartPosition:(float)startPosition
                      endPosition:(float)endPosition
                         duration:(NSTimeInterval)duration
{
    NSDictionary *userInfo = @{
        @"start_position": @(startPosition),
        @"end_position": @(endPosition),
        @"duration": @(duration)
    };
    [self trigger:CLPContainerEventProgress userInfo:userInfo];
}

- (void)timeUpdatedWithPosition:(float)position
                       duration:(NSTimeInterval)duration
{
    NSDictionary *userInfo = @{
        @"position": @(position),
        @"duration": @(duration)
    };
    [self trigger:CLPContainerEventTimeUpdate userInfo:userInfo];
}

- (void)ready
{
    _ready = YES;
    [self trigger:CLPContainerEventReady];
}

- (void)buffering
{
    [self trigger:CLPContainerEventBuffering];
}

- (void)bufferFull
{
    [self trigger:CLPContainerEventBufferFull];
}

- (void)settingsUpdated
{
    _settings = _playback.settings;
    [self trigger:CLPContainerEventSettingsUpdated];
}

- (void)loadedMetadataWithDuration:(NSTimeInterval)duration
{
    NSDictionary *userInfo = @{@"duration": @(duration)};
    [self trigger:CLPContainerEventLoadedMetadata userInfo:userInfo];
}

- (void)highDefinitionUpdated
{
    [self trigger:CLPContainerEventHighDefinitionUpdated];
}

- (void)updateBitrate:(float)bitRate
{
    NSDictionary *userInfo = @{@"bit_rate": @(bitRate)};
    [self trigger:CLPContainerEventBitRate userInfo:userInfo];
}

- (void)statsReport
{
    // check what we need to do here
    [self trigger:CLPContainerEventStatsReport];
}

- (void)stateChanged
{
    [self trigger:CLPContainerEventPlaybackStateChanged];
}

- (void)dvrStateChanged:(BOOL)dvrInUse
{
    _settings = _playback.settings;
    _dvrInUse = dvrInUse;

    NSDictionary *userInfo = @{@"dvr_in_use": @(dvrInUse)};
    [self trigger:CLPContainerEventPlaybackStateDVRStateChanged userInfo:userInfo];
}

- (void)disableMediaControl
{
    _mediaControlDisabled = YES;
    [self trigger:CLPContainerEventMediaControlDisabled];
}

- (void)enableMediaControl
{
    _mediaControlDisabled = NO;
    [self trigger:CLPContainerEventMediaControlEnabled];
}

- (void)ended
{
    [self trigger:CLPContainerEventEnded];
}

- (void)error:(NSError *)errorObj
{
    [self trigger:CLPContainerEventError userInfo:@{@"error": errorObj}];
}

- (void)play
{
    [_playback play];
    [self trigger:CLPContainerEventPlay];
}

- (void)pause
{
    [_playback pause];
    [self trigger:CLPContainerEventPause];
}

- (void)stop
{
    [_playback stop];
    [self trigger:CLPContainerEventStop];
}

- (void)destroy
{
    [self stopListening];
    [_playback destroy];

    [self.view removeFromSuperview];
    
    [self trigger:CLPContainerEventDestroyed];
}

- (void)addPlugin:(id)plugin
{
    if ([[plugin class] isSubclassOfClass:[CLPUIContainerPlugin class]]) {
        CLPUIContainerPlugin *containerPlugin = (CLPUIContainerPlugin *)plugin;
        containerPlugin.container = self;
        [p_plugins addObject:containerPlugin];
        [self.view addSubview:containerPlugin.view];
    }
}

- (BOOL)hasPlugin:(Class)pluginClass
{
    for (id plugin in p_plugins) {
        if ([plugin class] == pluginClass) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Accessors

- (BOOL)isPlaying
{
    return [_playback isPlaying];
}

- (void)setPlayback:(CLPPlayback *)playback
{
    _playback = playback;

    [self stopListening];
    [self bindEventListeners];
}

//- (NSArray *)plugins
//{
//    return [plugins copy];
//}

@end
