#import "CLPUIObject.h"

extern NSString *const CLPContainerEventPlaybackStateChanged;
extern NSString *const CLPContainerEventPlaybackStateDVRStateChanged;
extern NSString *const CLPContainerEventBitRate;
extern NSString *const CLPContainerEventStatsReport;
extern NSString *const CLPContainerEventDestroyed;
extern NSString *const CLPContainerEventReady;
extern NSString *const CLPContainerEventError;
extern NSString *const CLPContainerEventLoadedMetadata;
extern NSString *const CLPContainerEventTimeUpdate;
extern NSString *const CLPContainerEventProgress;
extern NSString *const CLPContainerEventPlay;
extern NSString *const CLPContainerEventStop;
extern NSString *const CLPContainerEventPause;
extern NSString *const CLPContainerEventEnded;
extern NSString *const CLPContainerEventTap;
extern NSString *const CLPContainerEventSeek;
extern NSString *const CLPContainerEventVolume;
extern NSString *const CLPContainerEventFullscreen;
extern NSString *const CLPContainerEventBuffering;
extern NSString *const CLPContainerEventBufferFull;
extern NSString *const CLPContainerEventSettingsUpdated;
extern NSString *const CLPContainerEventHighDefinitionUpdated;
extern NSString *const CLPContainerEventMediaControlDisabled;
extern NSString *const CLPContainerEventMediaControlEnabled;

@class CLPPlayback;

@interface CLPContainer : CLPUIObject

@property (nonatomic, strong, readwrite) CLPPlayback *playback;
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly) NSDictionary *settings;
@property (nonatomic, assign, readonly, getter=isDVRInUse) BOOL dvrInUse;
@property (nonatomic, assign, readonly, getter=isMediaControlDisabled) BOOL mediaControlDisabled;

- (instancetype)initWithPlayback:(CLPPlayback *)playback;

- (void)play;
- (void)pause;
- (void)stop;
- (void)destroy;

@end
