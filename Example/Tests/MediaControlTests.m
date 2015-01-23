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

    NSURL *sourceURL = [NSURL URLWithString:@"http://globo.com/video.mp4"];

    beforeEach(^{
        playback = [[CLPPlayback alloc] initWithURL:sourceURL];
        container = [[CLPContainer alloc] initWithPlayback:playback];
        mediaControl = [[CLPMediaControl alloc] initWithContainer:container];
    });

    describe(@"Play", ^{

        it(@"should contain a play/pause button embed in its view", ^{
            UIButton *playPauseButton = mediaControl.playPauseButton;
            [[playPauseButton.superview should] equal:mediaControl.view];
        });

        it(@"should be triggered after touch the button when it is not playing", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(NO)];

            [[mediaControl should] receive:@selector(play)];

            [mediaControl.playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should call container play after its play method has been called", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(NO)];

            [[container should] receive:@selector(play)];

            [mediaControl.playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should trigger playing event after listen to container's play event", ^{

            __block BOOL callbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventPlaying callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            [container trigger:CLPContainerEventPlay];

            [[theValue(callbackWasCalled) should] beTrue];
        });
    });

    describe(@"Pause", ^{

        it(@"should be triggered after touch the button when it is playing", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(YES)];

            [[mediaControl should] receive:@selector(pause)];

            [mediaControl.playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should call container pause after its pause method has been called", ^{

            [container stub:@selector(isPlaying) andReturn:theValue(YES)];

            [[container should] receive:@selector(pause)];

            [mediaControl.playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should trigger 'not playing event' after listen to container's pause event", ^{

            __block BOOL callbackWasCalled = NO;
            [mediaControl once:CLPMediaControlEventNotPlaying callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            [container trigger:CLPContainerEventPause];

            [[theValue(callbackWasCalled) should] beTrue];
        });

    });

    describe(@"Current Time", ^{

        it(@"should contain a label displaying the current playback time", ^{
            UILabel *currentTimeLabel = [mediaControl valueForKey:@"_currentTimeLabel"];
            [[currentTimeLabel.text should] equal:@"0:00"];
        });

        pending(@"should update its value after listen to playback's current time update", ^{

        });

    });
});

SPEC_END