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
            [[mediaControl.currentTimeLabel.text should] equal:@"00:00"];
        });

        it(@"should update its value after listen to playback's current time update", ^{
            NSDictionary *userInfo = @{@"position": @78};

            [playback trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];

            [[mediaControl.currentTimeLabel.text should] equal:@"01:18"];
        });

        it(@"should be able to display current time greater than 1 hour", ^{
            NSUInteger position = (1 * 60 * 60) + (54 * 60) + 32;
            NSDictionary *userInfo = @{@"position": @(position)};
            [playback trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];

            [[mediaControl.currentTimeLabel.text should] equal:@"01:54:32"];
        });
    });

    describe(@"Duration", ^{

        it(@"should display its initial value", ^{
            [[mediaControl.durationLabel.text should] equal:@"00:00"];
        });

        it(@"should contain a label displaying the playback's duration", ^{
            [playback stub:@selector(duration) andReturn:theValue(36)];
            [container trigger:CLPContainerEventReady userInfo:nil];
            [[mediaControl.durationLabel.text should] equal:@"00:36"];
        });
    });

    context(@"Controls Visibility", ^{

        it(@"should start visible", ^{
            [[theValue(mediaControl.playPauseButton.hidden) should] beFalse];
            [[theValue(mediaControl.controlsWrapperView.hidden) should] beFalse];
            [[theValue(mediaControl.controlsOverlayView.hidden) should] beFalse];
        });

        it(@"should hide its controls after call hide", ^{

            [mediaControl hide];

            [[expectFutureValue(theValue(mediaControl.playPauseButton.hidden)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(mediaControl.controlsWrapperView.hidden)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(mediaControl.controlsOverlayView.hidden)) shouldEventually] beTrue];
        });

        it(@"should show its controls again after call hide and then show", ^{

            [mediaControl hide];

            [[expectFutureValue(theValue(mediaControl.playPauseButton.hidden)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(mediaControl.controlsWrapperView.hidden)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(mediaControl.controlsOverlayView.hidden)) shouldEventually] beTrue];

            [mediaControl show];

            [[expectFutureValue(theValue(mediaControl.playPauseButton.hidden)) shouldEventually] beFalse];
            [[expectFutureValue(theValue(mediaControl.controlsWrapperView.hidden)) shouldEventually] beFalse];
            [[expectFutureValue(theValue(mediaControl.controlsOverlayView.hidden)) shouldEventually] beFalse];
        });
    });

    context(@"General", ^{

        it(@"should reset it's play button state after listen to container's end event", ^{
            [mediaControl.playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];

            [[theValue(mediaControl.playPauseButton.selected) should] beTrue];

            [container trigger:CLPContainerEventEnded];

            [[theValue(mediaControl.playPauseButton.selected) should] beFalse];
        });
    });
});

SPEC_END