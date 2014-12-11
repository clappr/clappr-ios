//
//  CLPPlayback.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPPlayback.h"

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
