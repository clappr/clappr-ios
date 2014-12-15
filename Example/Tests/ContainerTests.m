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

        it(@"should have a default name", ^{
            [[container.name should] equal:@"Container"];
        });
    });

    context(@"event binding", ^{

        beforeEach(^{
            playback = [CLPPlayback new];
            container = [[CLPContainer alloc] initWithPlayback:playback];
        });

        it(@"should listen to playback's progress event", ^{
            CGFloat startPosition = 0.0f, endPosition = 15.4f;
            NSTimeInterval duration = 10.0f;
            [[container should] receive:@selector(progressWithStartPosition:endPosition:duration:)
                          withArguments:theValue(startPosition), theValue(endPosition), theValue(duration)];

            NSDictionary *userInfo = @{
                @"startPosition": @(startPosition),
                @"endPosition": @(endPosition),
                @"duration": @(duration)
            };

            [playback trigger:CLPPlaybackEventProgress userInfo:userInfo];
        });

        it(@"should listen to playback's time updated event", ^{
            CGFloat position = 10.3f;
            NSTimeInterval duration = 12.78;
            [[container should] receive:@selector(timeUpdatedWithPosition:duration:) withArguments:theValue(position), theValue(duration)];

            NSDictionary *userInfo = @{
                @"position": @(position),
                @"duration":@(duration)
            };

            [playback trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];
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