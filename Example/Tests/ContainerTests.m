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
            [[container should] receive:@selector(progress)];
            [playback trigger:CLPPlaybackEventProgress];
        });

        it(@"should listen to playback's time updated event", ^{
            [[container should] receive:@selector(timeUpdated)];
            [playback trigger:CLPPlaybackEventTimeUpdated];
        });

        it(@"should listen to playback's ready event", ^{
            [[container should] receive:@selector(ready)];
            [playback trigger:CLPPlaybackEventReady];
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
            [[container should] receive:@selector(settingsUpdated)];
            [playback trigger:CLPPlaybackEventSettingsUdpdated];
        });

        it(@"should listen to playback's loaded metadata event", ^{
            [[container should] receive:@selector(loadedMetadata)];
            [playback trigger:CLPPlaybackEventLoadedMetadata];
        });

        it(@"should listen to playback's HD update event", ^{
            [[container should] receive:@selector(highDefinitionUpdated)];
            [playback trigger:CLPPlaybackEventHighDefinitionUpdate];
        });

        it(@"should listen to playback's bit rate event", ^{
            [[container should] receive:@selector(updateBitrate)];
            [playback trigger:CLPPlaybackEventBitRate];
        });

        it(@"should listen to playback's state changed event", ^{
            [[container should] receive:@selector(stateChanged)];
            [playback trigger:CLPPlaybackEventStateChanged];
        });

        it(@"should listen to playback's DVR state changed event", ^{
            [[container should] receive:@selector(dvrStateChanged)];
            [playback trigger:CLPPlaybackEventDVRStateChanged];
        });

        it(@"should listen to playback's disable media control event", ^{
            [[container should] receive:@selector(disableMediaControl)];
            [playback trigger:CLPPlaybackEventMediaControlDisabled];
        });

        it(@"should listen to playback's enable media control event", ^{
            [[container should] receive:@selector(enableMediaControl)];
            [playback trigger:CLPPlaybackEventMediaControlEnabled];
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
            [[container should] receive:@selector(error)];
            [playback trigger:CLPPlaybackEventError];
        });
    });
});

SPEC_END