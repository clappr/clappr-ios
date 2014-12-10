//
//  PlayerView.m
//  Clappr
//
//  Created by Thiago Pontes on 8/14/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayerView

+ (Class) layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer*) playerLayer
{
    return (AVPlayerLayer*) self.layer;
}

- (AVPlayer*) player
{
    return [self playerLayer].player;
}

- (void) setPlayer:(AVPlayer *)player
{
    [self playerLayer].player = player;
}

@end
