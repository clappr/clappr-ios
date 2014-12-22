//
//  MediaControlTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/18/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>
#import <objc/runtime.h>

SPEC_BEGIN(MediaControl)

describe(@"Media Control", ^{

    __block CLPMediaControl *mediaControl;
    __block CLPContainer *container;
    __block CLPPlayback *playback;

    beforeEach(^{
        playback = [[CLPPlayback alloc] init];
        container = [[CLPContainer alloc] initWithPlayback:playback];
        mediaControl = [[CLPMediaControl alloc] initWithContainer:container];
    });

    it(@"should have a volume property accepting values between 0 and 100", ^{
        mediaControl.volume = 57.0;
        [[theValue(mediaControl.volume) should] equal:theValue(57.0)];
    });

    it(@"should not have a volume less than 0", ^{
        mediaControl.volume = -45.0f;
        [[theValue(mediaControl.volume) should] equal:theValue(0.0)];
    });

    it(@"should not have a volume greater than 100", ^{
        mediaControl.volume = 101.2;
        [[theValue(mediaControl.volume) should] equal:theValue(100.0)];
    });

    it(@"should call container play after its play method has been called", ^{
        [[container should] receive:@selector(play)];
        [mediaControl play];
    });


    describe(@"Event listening", ^{

        it(@"should toggle play after listen to container's play event", ^{

        });

        it(@"should trigger media control's playing event after listen to container's play event when container is playing", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(YES)];

            __block BOOL playingCallbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventPlaying callback:^(NSDictionary *userInfo) {
                playingCallbackWasCalled = YES;
            }];

            __block BOOL notPlayingCallbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventNotPlaying callback:^(NSDictionary *userInfo) {
                notPlayingCallbackWasCalled = YES;
            }];

            [container trigger:CLPContainerEventPlay];

            [[theValue(playingCallbackWasCalled) should] beTrue];
            [[theValue(notPlayingCallbackWasCalled) should] beFalse];
        });

        it(@"should trigger media control's not playing event after listen to container's play event when container is not playing", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(NO)];

            __block BOOL playingCallbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventPlaying callback:^(NSDictionary *userInfo) {
                playingCallbackWasCalled = YES;
            }];

            __block BOOL notPlayingCallbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventNotPlaying callback:^(NSDictionary *userInfo) {
                notPlayingCallbackWasCalled = YES;
            }];

            [container trigger:CLPContainerEventPlay];

            [[theValue(playingCallbackWasCalled) should] beFalse];
            [[theValue(notPlayingCallbackWasCalled) should] beTrue];
        });

        it(@"should update seek bar after listen to container's time update event", ^{
            
        });

        it(@"should update progress bar after listen to container's progress event", ^{

        });

        it(@"should handle container's settings update event properly", ^{

        });

        it(@"should handle container's DVR state event properly ", ^{

        });

        it(@"should handle container's HD update properly", ^{

        });

        it(@"should disable after listen to container's media control disable event", ^{

        });

        it(@"should enable after listen to container's media control enable event", ^{

        });

        it(@"should handle container's ended event properly", ^{

        });
    });
});

SPEC_END