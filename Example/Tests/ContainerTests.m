//
//  ContainerTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>

SPEC_BEGIN(Container)

describe(@"Container", ^{

    __block CLPContainer *container;
    __block CLPPlayback *playback;

    context(@"Instantiation", ^{

        it(@"cannot be instatiated without a playback", ^{
            [[theBlock(^{
                [CLPContainer new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"should receive a playback in the constructor", ^{
            playback = [CLPPlayback new];
            container = [[CLPContainer alloc] initWithPlayback:playback];
            [[container.playback should] equal:playback];
        });
    });

    context(@"General", ^{

        beforeEach(^{
            playback = [CLPPlayback new];
            container = [[CLPContainer alloc] initWithPlayback:playback];
        });

        it(@"can be destroyed properly", ^{
            UIView *wrapperView = [UIView new];
            [wrapperView addSubview:container.view];

            __block NSString *containerName;
            [container once:CLPContainerEventDestroyed callback:^(NSDictionary *userInfo) {
                containerName = userInfo[@"name"];
            }];

            [[playback should] receive:@selector(destroy)];
            [container destroy];
            [[container.view.superview should] beNil];
            [[containerName should] equal:@"Container"];
        });

        it(@"should call playback's play method after its play method has been called", ^{
            [[playback should] receive:@selector(play)];
            [container play];
        });

        it(@"should call playback's pause method after its pause method has been called", ^{
            [[playback should] receive:@selector(pause)];
            [container pause];
        });
    });

    context(@"event binding", ^{

        beforeEach(^{
            playback = [CLPPlayback new];
            container = [[CLPContainer alloc] initWithPlayback:playback];
        });

        it(@"should trigger its event after listen to playback's progress event with the respective params", ^{
            // Given
            float expectedStartPosition = 0.7f, expectedEndPosition = 15.4f;
            NSTimeInterval expectedDuration = 10.0f;

            __block float startPosition, endPosition;
            __block NSTimeInterval duration;

            [container once:CLPContainerEventProgress callback:^(NSDictionary *userInfo) {
                startPosition = [userInfo[@"start_position"] floatValue];
                endPosition = [userInfo[@"end_position"] floatValue];
                duration = [userInfo[@"duration"] doubleValue];
            }];

            // When
            NSDictionary *userInfo = @{
                @"start_position": @(expectedStartPosition),
                @"end_position": @(expectedEndPosition),
                @"duration": @(expectedDuration)
            };
            [playback trigger:CLPPlaybackEventProgress userInfo:userInfo];

            // Then
            [[theValue(startPosition) should] equal:theValue(expectedStartPosition)];
            [[theValue(endPosition) should] equal:theValue(expectedEndPosition)];
            [[theValue(duration) should] equal:theValue(expectedDuration)];
        });

        it(@"should trigger its event after listen to playback's time updated event with the respective params", ^{
            // Given
            float expectedPosition = 10.3f;
            NSTimeInterval expectedDuration = 12.78;

            __block float position = 0.0;
            __block NSTimeInterval duration = 0.0;
            [container once:CLPContainerEventTimeUpdate callback:^(NSDictionary *userInfo) {
                position = [userInfo[@"position"] floatValue];
                duration = [userInfo[@"duration"] doubleValue];
            }];

            // When
            NSDictionary *userInfo = @{
                @"position": @(expectedPosition),
                @"duration":@(expectedDuration)
            };
            [playback trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];

            // Then
            [[theValue(position) should] equal:theValue(expectedPosition)];
            [[theValue(duration) should] equal:theValue(expectedDuration)];
        });

        it(@"should be ready after listen to playback's ready event", ^{
            [[theValue([container isReady]) should] beFalse];

            [playback trigger:CLPPlaybackEventReady];

            [[theValue([container isReady]) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's buffering event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventBuffering callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventBuffering];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's buffer full event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventBufferFull callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventBufferFull];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should update its settings after listen to playback's settings update event", ^{
            [playback stub:@selector(settings) andReturn:@{@"foo": @"bar"}];

            [playback trigger:CLPPlaybackEventSettingsUdpdated];

            [[container.settings should] equal:@{@"foo": @"bar"}];
        });

        it(@"should trigger its event after listen to playback settings update event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventSettingsUpdated callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventSettingsUdpdated];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's loaded metadata event with the respective params", ^{
            NSTimeInterval expectedDuration = 20.0;

            __block NSTimeInterval duration = 0.0;
            [container once:CLPContainerEventLoadedMetadata callback:^(NSDictionary *userInfo) {
                duration = [userInfo[@"duration"] doubleValue];
            }];

            NSDictionary *userInfo = @{@"duration":@(expectedDuration)};
            [playback trigger:CLPPlaybackEventLoadedMetadata userInfo:userInfo];

            [[theValue(duration) should] equal:theValue(expectedDuration)];
        });

        it(@"should trigger its event after listen to playback's HD update event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventHighDefinitionUpdated callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventHighDefinitionUpdate];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's bit rate event with the respective params", ^{
            float expectedBitRate = 12.34;

            __block float bitRate = 0.0;
            [container once:CLPContainerEventBitRate callback:^(NSDictionary *userInfo) {
                bitRate = [userInfo[@"bit_rate"] floatValue];
            }];

            NSDictionary *userInfo = @{@"bit_rate": @(expectedBitRate)};
            [playback trigger:CLPPlaybackEventBitRate userInfo:userInfo];

            [[theValue(bitRate) should] equal:theValue(expectedBitRate)];
        });

        it(@"should trigger its event after listen to playback's state changed event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventPlaybackStateChanged callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventStateChanged];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's DVR state changed event with the respective params", ^{
            __block BOOL dvrInUse = NO;
            [container once:CLPContainerEventPlaybackStateDVRStateChanged callback:^(NSDictionary *userInfo) {
                dvrInUse = [userInfo[@"dvr_in_use"] boolValue];
            }];

            [playback trigger:CLPPlaybackEventDVRStateChanged userInfo:@{@"dvr_in_use": @(YES)}];

            [[theValue(dvrInUse) should] beTrue];
        });

        it(@"should update dvrInUse flag after listen to playback's DVR state changed event", ^{
            [[theValue(container.dvrInUse) should] beFalse];

            NSDictionary *userInfo = @{@"dvr_in_use": @(YES)};
            [playback trigger:CLPPlaybackEventDVRStateChanged userInfo:userInfo];

            [[theValue(container.dvrInUse) should] beTrue];
        });

        it(@"should update its settings after listen to playback's DVR state changed event", ^{
            [playback stub:@selector(settings) andReturn:@{@"foo": @"bar"}];

            [[container.settings should] beNil];

            [playback trigger:CLPPlaybackEventDVRStateChanged];

            [[container.settings should] equal:@{@"foo": @"bar"}];
        });

        it(@"should disable media control after listen to playback's disable media control event", ^{
            [playback trigger:CLPPlaybackEventMediaControlDisabled];
            [[theValue(container.mediaControlDisabled) should] beTrue];
        });

        it(@"should trigger its event after listen to playbacks's disable media control event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventMediaControlDisabled callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventMediaControlDisabled];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should enable media control after listen to playback's enable media control event", ^{
            // just to not get the default value and we think the test
            // result is what we're expecting
            [container setValue:@(YES) forKey:@"mediaControlDisabled"];

            [playback trigger:CLPPlaybackEventMediaControlEnabled];
            [[theValue(container.mediaControlDisabled) should] beFalse];
        });

        it(@"should trigger its event after listen to playbacks's enable media control event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventMediaControlEnabled callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventMediaControlEnabled];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's end event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventEnded callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventEnded];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its play event after listen to playback's play event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventPlay callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventPlay];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its pause event after listen to playback's pause event", ^{
            __block BOOL eventWasTriggered = NO;
            [container once:CLPContainerEventPause callback:^(NSDictionary *userInfo) {
                eventWasTriggered = YES;
            }];

            [playback trigger:CLPPlaybackEventPause];

            [[theValue(eventWasTriggered) should] beTrue];
        });

        it(@"should trigger its event after listen to playback's error event with respective params", ^{
            NSError *expectedErrorObject = [NSError new];

            __block NSError *error = nil;
            [container once:CLPContainerEventError callback:^(NSDictionary *userInfo) {
                error = expectedErrorObject;
            }];

            [playback trigger:CLPPlaybackEventError userInfo:@{@"error":expectedErrorObject}];

            [[error should] equal:expectedErrorObject];
        });
    });
});

SPEC_END