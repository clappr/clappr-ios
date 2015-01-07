//
//  CLPMediaControl.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/18/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPMediaControl.h"
#import "CLPContainer.h"

NSString *const CLPMediaControlEventPlaying = @"clappr:media_control:playing";
NSString *const CLPMediaControlEventNotPlaying = @"clappr:media_control:not_playing";

@implementation CLPMediaControl

#pragma mark - Ctors

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;

        _playPauseButton = [UIButton new];
        [_playPauseButton addTarget:self action:@selector(togglePlay) forControlEvents:UIControlEventTouchUpInside];
        [_container.view addSubview:_playPauseButton];

        [self bindEventListeners];
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

}

#pragma mark - Accessors

- (void)setVolume:(float)volume
{
    if (volume < 0.0) {
        _volume = 0.0;
    } else if (volume > 100.0) {
        _volume = 100.0;
    } else {
        _volume = volume;
    }
}

#pragma mark - Methods

- (void)play
{
    [_container play];
    [self trigger:CLPMediaControlEventPlaying];
}

- (void)pause
{
    [_container pause];
    [self trigger:CLPMediaControlEventNotPlaying];
}

- (void)togglePlay
{
    if ([_container isPlaying]) {
        [self pause];
    } else {
        [self play];
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

@end
