//
//  PlaybackTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>
#import <objc/runtime.h>

SPEC_BEGIN(Playback)

describe(@"Playback", ^{

    __block CLPPlayback *playback;

    beforeAll(^{
        playback = [CLPPlayback new];
    });

    it(@"should have a play method", ^{
        BOOL responds = [playback respondsToSelector:@selector(play)];
        [[theValue(responds) should] beTrue];
    });

    it(@"should have a pause method", ^{
        BOOL responds = [playback respondsToSelector:@selector(pause)];
        [[theValue(responds) should] beTrue];
    });

    it(@"should have a stop method", ^{
        BOOL responds = [playback respondsToSelector:@selector(stop)];
        [[theValue(responds) should] beTrue];
    });

    it(@"should have a seekTo method receiving the time", ^{
        [[theBlock(^{
            [playback seekTo:10];
        }) shouldNot] raise];
    });

    it(@"should have a volume property with a default value 0 and settable", ^{
        [[theValue(playback.volume) should] equal:theValue(0)];

        playback.volume = 0.5f;

        [[theValue(playback.volume) should] equal:theValue(0.5f)];
    });

    it(@"should have a duration property with a default value 0", ^{
        [[theValue(playback.duration) should] equal:theValue(0)];
    });

    it(@"should have a playing property with a default value NO", ^{
        [[theValue(playback.playing) should] equal:theValue(NO)];
    });

    it(@"should responds to isPlaying as a getter to the property", ^{
        BOOL responds = [playback respondsToSelector:@selector(isPlaying)];
        [[theValue(responds) should] beTrue];
    });

    it(@"should have a type property with a default value unknown", ^{
        [[theValue(playback.type) should] equal:theValue(CLPPlaybackTypeUnknown)];
    });

    it(@"should have a highDefinitionInUse property with a default value NO", ^{
        [[theValue(playback.highDefinitionInUse) should] equal:theValue(NO)];
    });

    it(@"should responds to isHighDefinitionInUse as a getter to the property", ^{
        BOOL responds = [playback respondsToSelector:@selector(isHighDefinitionInUse)];
        [[theValue(responds) should] beTrue];
    });

    it(@"should be removed from superview when call destroy", ^{
        UIView *containerView = [UIView new];
        [containerView addSubview:playback.view];

        [playback destroy];

        [[playback.view.superview should] beNil];
    });

    it(@"should have a class method to check if a source can be played and its default value is NO", ^{
        BOOL canPlay = [playback canPlayURL:[NSURL new]];
        [[theValue(canPlay) should] equal:theValue(NO)];
    });
});

SPEC_END