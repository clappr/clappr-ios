//
//  CLPPlayback.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPPlayback.h"

NSString *const CLPPlaybackEventProgress = @"clappr:playback:progress";
NSString *const CLPPlaybackEventProgressStartPositionKey = @"startPosition";
NSString *const CLPPlaybackEventProgressEndPositionKey = @"endPosition";
NSString *const CLPPlaybackEventProgressDurationKey = @"duration";

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
NSString *const CLPPlaybackEventError = @"clappr:playback:error";

@implementation CLPPlayback

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

- (BOOL)canPlayURL:(NSURL *)url
{
    return NO;
}

- (void)destroy
{
    [self.view removeFromSuperview];
}

@end
