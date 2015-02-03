#import "CLPUIObject.h"

#import "PlayerView.h"

extern NSString *const CLPPlaybackEventProgress;
extern NSString *const CLPPlaybackEventTimeUpdated;
extern NSString *const CLPPlaybackEventReady;
extern NSString *const CLPPlaybackEventBuffering;
extern NSString *const CLPPlaybackEventBufferFull;
extern NSString *const CLPPlaybackEventSettingsUdpdated;
extern NSString *const CLPPlaybackEventLoadedMetadata;
extern NSString *const CLPPlaybackEventHighDefinitionUpdate;
extern NSString *const CLPPlaybackEventBitRate;
extern NSString *const CLPPlaybackEventStateChanged;
extern NSString *const CLPPlaybackEventDVRStateChanged;
extern NSString *const CLPPlaybackEventMediaControlDisabled;
extern NSString *const CLPPlaybackEventMediaControlEnabled;
extern NSString *const CLPPlaybackEventEnded;
extern NSString *const CLPPlaybackEventPlay;
extern NSString *const CLPPlaybackEventPause;
extern NSString *const CLPPlaybackEventError;

typedef NS_ENUM(NSUInteger, CLPPlaybackType) {
    CLPPlaybackTypeUnknown
};

@interface CLPPlayback : CLPUIObject

@property (nonatomic, strong, readonly) PlayerView *playerView;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) NSUInteger duration;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly) CLPPlaybackType type;
@property (nonatomic, assign, readonly, getter=isHighDefinitionInUse) BOOL highDefinitionInUse;
@property (nonatomic, assign, readonly) NSDictionary *settings;

- (instancetype)initWithURL:(NSURL *)url;

- (void)play;
- (void)pause;
- (void)stop;
- (void)seekTo:(NSTimeInterval)timeInterval;

+ (BOOL)canPlayURL:(NSURL *)url;
- (void)destroy;

@end
