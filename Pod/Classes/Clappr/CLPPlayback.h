//
//  CLPPlayback.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPUIObject.h"

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

@property (nonatomic, assign, readwrite) CGFloat volume;
@property (nonatomic, assign, readonly) NSUInteger duration;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly) CLPPlaybackType type;
@property (nonatomic, assign, readonly, getter=isHighDefinitionInUse) BOOL highDefinitionInUse;
@property (nonatomic, assign, readonly) NSDictionary *settings;

- (void)play;
- (void)pause;
- (void)stop;
- (void)seekTo:(NSTimeInterval)timeInterval;

- (BOOL)canPlayURL:(NSURL *)url;
- (void)destroy;

@end
