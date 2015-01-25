//
//  CLPPlayback.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPPlayback.h"

// System
#import <AVFoundation/AVFoundation.h>

// Clappr
#import "PlayerView.h"
#import "UIView+NSLayoutConstraints.h"

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

@interface CLPPlayback ()
{
    PlayerView *playerView;
}
@property (nonatomic, strong) AVPlayer *avPlayer;

@end

@implementation CLPPlayback

#pragma mark - Ctors

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;

        playerView = [PlayerView new];
        [self.view clappr_addSubviewMatchingFrameOfView:playerView];

        [self bindEventListeners];

        if (_url) {
            _avPlayer = [AVPlayer playerWithURL:_url];
            [playerView setPlayer:_avPlayer];
            [_avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
            [self addTimeElapsedCallbackHandler];
        }
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithURL: instead"
                                 userInfo:nil];
}

#pragma mark - Dtor

- (void)dealloc
{
    [_avPlayer removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)bindEventListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_avPlayer.currentItem];
}

- (void)addTimeElapsedCallbackHandler
{
    __weak typeof(self) weakSelf = self;
    [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:nil usingBlock:^(CMTime time) {

        NSDictionary *userInfo = @{
            @"position": @(CMTimeGetSeconds(time)),
            @"duration": @(CMTimeGetSeconds(weakSelf.avPlayer.currentItem.asset.duration))
        };

        [weakSelf trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];
    }];
}

#pragma mark - Controls

- (void)play
{
    [_avPlayer play];
}

- (void)pause
{
    [_avPlayer pause];
}

- (void)stop
{
}

- (void)seekTo:(NSTimeInterval)timeInterval
{
}

- (BOOL)canPlayURL:(NSURL *)url
{
    return NO;
}

- (void)destroy
{
    [self.view removeFromSuperview];
}

#pragma mark - Accessors

- (NSUInteger)duration
{
    BOOL playerIsReady = _avPlayer.status == AVPlayerStatusReadyToPlay;
    if (!playerIsReady)
        return 0;

    return CMTimeGetSeconds(_avPlayer.currentItem.asset.duration);
}

- (BOOL)isPlaying
{
    return _avPlayer.rate > 0.0f;
}

#pragma mark - Playback event handlers

- (void)playbackDidEnd
{
    [_avPlayer.currentItem seekToTime:kCMTimeZero];
    [self trigger:CLPPlaybackEventEnded];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == _avPlayer && [keyPath isEqualToString:@"status"]) {
        if (_avPlayer.status == AVPlayerStatusReadyToPlay) {
            [self trigger:CLPPlaybackEventReady];
        } else if (_avPlayer.status == AVPlayerStatusFailed) {
            [self trigger:CLPPlaybackEventError];
        }
    }
}

@end
