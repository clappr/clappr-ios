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

        it(@"can be destroyed property", ^{
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
    });

    context(@"event binding", ^{

        beforeEach(^{
            playback = [CLPPlayback new];
            container = [[CLPContainer alloc] initWithPlayback:playback];
        });

        it(@"should listen to playback's progress event", ^{
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

        it(@"should listen to playback's time updated event", ^{
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

        it(@"should listen to playback's ready event", ^{
            [[theValue([container isReady]) should] beFalse];

            [playback trigger:CLPPlaybackEventReady];

            [[theValue([container isReady]) should] beTrue];
        });

        it(@"should listen to playback's buffering event", ^{
            [[container should] receive:@selector(buffering)];
            [playback trigger:CLPPlaybackEventBuffering];
        });

        it(@"should listen to playback's buffer full event", ^{
            [[container should] receive:@selector(bufferFull)];
            [playback trigger:CLPPlaybackEventBufferFull];
        });

        it(@"should listen to playback's settings update event", ^{
            [playback stub:@selector(settings) andReturn:@{@"foo": @"bar"}];

            [playback trigger:CLPPlaybackEventSettingsUdpdated];

            [[container.settings should] equal:playback.settings];
        });

        it(@"should listen to playback's loaded metadata event", ^{
            NSTimeInterval duration = 20;

            [[container should] receive:@selector(loadedMetadataWithDuration:)
                          withArguments:theValue(duration)];

            NSDictionary *userInfo = @{@"duration":@(duration)};
            [playback trigger:CLPPlaybackEventLoadedMetadata userInfo:userInfo];
        });

        it(@"should listen to playback's HD update event", ^{
            [[container should] receive:@selector(highDefinitionUpdated)];
            [playback trigger:CLPPlaybackEventHighDefinitionUpdate];
        });

        it(@"should listen to playback's bit rate event", ^{
            float bitRate = 12.34;
            [[container should] receive:@selector(updateBitrate:)
                          withArguments:theValue(bitRate)];

            NSDictionary *userInfo = @{@"bit_rate": @(bitRate)};

            [playback trigger:CLPPlaybackEventBitRate userInfo:userInfo];

            // param newBitrate
            // this.trigger(Events.CONTAINER_BITRATE, newBitrate)
        });

        it(@"should listen to playback's state changed event", ^{
            [[container should] receive:@selector(stateChanged)];
            [playback trigger:CLPPlaybackEventStateChanged];
        });

        it(@"should listen to playback's DVR state changed event", ^{
            [[theValue(container.dvrInUse) should] beFalse];

            NSDictionary *userInfo = @{@"dvr_in_use": @(YES)};
            [playback trigger:CLPPlaybackEventDVRStateChanged userInfo:userInfo];

            [[theValue(container.dvrInUse) should] beTrue];
        });

        it(@"should listen to playback's disable media control event", ^{
            [playback trigger:CLPPlaybackEventMediaControlDisabled];
            [[theValue(container.mediaControlDisabled) should] beTrue];
        });

        it(@"should listen to playback's enable media control event", ^{
            [playback trigger:CLPPlaybackEventMediaControlEnabled];
            [[theValue(container.mediaControlDisabled) should] beFalse];
        });

        it(@"should listen to playback's end event", ^{
            [[container should] receive:@selector(ended)];
            [playback trigger:CLPPlaybackEventEnded];
        });

        it(@"should listen to playback's play event", ^{
            [[container should] receive:@selector(playing)];
            [playback trigger:CLPPlaybackEventPlay];
        });

        it(@"should listen to playback's error event", ^{
            NSError *errorObj = [NSError new];

            [[container should] receive:@selector(error:)
                          withArguments:errorObj];

            [playback trigger:CLPPlaybackEventError userInfo:@{@"error":errorObj}];
        });
    });
});

SPEC_END