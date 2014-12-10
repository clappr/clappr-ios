//
//  PlayerView.m
//  Clappr
//
//  Created by Thiago Pontes on 8/14/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerView ()

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@end


@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player
{
    self.playerLayer.player = player;
}

#pragma mark - Accessors

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end
