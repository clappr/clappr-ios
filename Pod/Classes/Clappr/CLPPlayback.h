//
//  CLPPlayback.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPUIObject.h"

typedef NS_ENUM(NSUInteger, CLPPlaybackType) {
    CLPPlaybackTypeUnknown
};

@interface CLPPlayback : CLPUIObject

@property (nonatomic, assign, readwrite) CGFloat volume;
@property (nonatomic, assign, readonly) NSUInteger duration;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly) CLPPlaybackType type;
@property (nonatomic, assign, readonly, getter=isHighDefinitionInUse) BOOL highDefinitionInUse;

- (void)play;
- (void)pause;
- (void)stop;
- (void)seekTo:(NSTimeInterval)timeInterval;

- (BOOL)canPlayURL:(NSURL *)url;
- (void)destroy;

@end
