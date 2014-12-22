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
        self.container = container;
        [self bindEventListeners];
    }
    return self;
}

- (void)bindEventListeners
{
    __weak typeof(self) weakSelf = self;
    [self listenTo:_container eventName:CLPContainerEventPlay callback:^(NSDictionary *userInfo) {
        [weakSelf togglePlay];
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
}

- (void)togglePlay
{
    if ([_container isPlaying]) {
        [self trigger:CLPMediaControlEventPlaying];
    } else {
        [self trigger:CLPMediaControlEventNotPlaying];
    }
}

@end
