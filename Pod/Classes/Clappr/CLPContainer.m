//
//  CLPContainer.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPContainer.h"

#import "CLPPlayback.h"


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
    }

    return self;
}

- (void)bindEventListeners
{
    __weak typeof(self) weakSelf = self;
    [self listenTo:_playback eventName:CLPPlaybackEventProgress callback:^(NSDictionary *userInfo) {
        CGFloat startPosition = [userInfo[CLPPlaybackEventProgressStartPositionKey] floatValue];
        CGFloat endPosition = [userInfo[CLPPlaybackEventProgressEndPositionKey] floatValue];
        NSTimeInterval duration = [userInfo[CLPPlaybackEventProgressDurationKey] doubleValue];
        [weakSelf progressWithStartPosition:startPosition endPosition:endPosition duration:duration];
    }];
    
    [self listenTo:_playback eventName:CLPPlaybackEventTimeUpdated callback:^(NSDictionary *userInfo) { [weakSelf timeUpdated]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventReady callback:^(NSDictionary *userInfo) { [weakSelf ready]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventBuffering callback:^(NSDictionary *userInfo) { [weakSelf buffering]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventBufferFull callback:^(NSDictionary *userInfo) { [weakSelf bufferFull]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventSettingsUdpdated callback:^(NSDictionary *userInfo) { [weakSelf settingsUpdated]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventLoadedMetadata callback:^(NSDictionary *userInfo) { [weakSelf loadedMetadata]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventHighDefinitionUpdate callback:^(NSDictionary *userInfo) { [weakSelf highDefinitionUpdated]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventBitRate callback:^(NSDictionary *userInfo) { [weakSelf updateBitrate]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventStateChanged callback:^(NSDictionary *userInfo) { [weakSelf stateChanged]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventDVRStateChanged callback:^(NSDictionary *userInfo) { [weakSelf dvrStateChanged]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventMediaControlDisabled callback:^(NSDictionary *userInfo) { [weakSelf disableMediaControl]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventMediaControlEnabled callback:^(NSDictionary *userInfo) { [weakSelf enableMediaControl]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventEnded callback:^(NSDictionary *userInfo) { [weakSelf ended]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventPlay callback:^(NSDictionary *userInfo) { [weakSelf playing]; }];
    [self listenTo:_playback eventName:CLPPlaybackEventError callback:^(NSDictionary *userInfo) { [weakSelf error]; }];
}

#pragma mark - Event Callbacks

- (void)progressWithStartPosition:(CGFloat)startPosition
                      endPosition:(CGFloat)endPosition
                         duration:(NSTimeInterval)duration
{
    NSLog(@">>>>>> %f, %f, %f", startPosition, endPosition, duration);
}

- (void)timeUpdated
{}

- (void)ready
{}

- (void)buffering
{}

- (void)bufferFull
{}

- (void)settingsUpdated
{}

- (void)loadedMetadata
{}

- (void)highDefinitionUpdated
{}

- (void)updateBitrate
{}

- (void)stateChanged
{}

- (void)dvrStateChanged
{}

- (void)disableMediaControl
{}

- (void)enableMediaControl
{}

- (void)ended
{}

- (void)playing
{}

- (void)error
{}

#pragma mark - Accessors

- (NSString *)name
{
    return @"Container";
}

- (void)setPlayback:(CLPPlayback *)playback
{
    _playback = playback;

    [self stopListening];
    [self bindEventListeners];
}

@end
