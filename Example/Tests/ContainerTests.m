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
                CLPPlaybackEventProgressStartPositionKey: @(startPosition),
                CLPPlaybackEventProgressEndPositionKey: @(endPosition),
                CLPPlaybackEventProgressDurationKey: @(duration)
            };

            [playback trigger:CLPPlaybackEventProgress userInfo:userInfo];
        });

        it(@"should listen to playback's time updated event", ^{
            [[container should] receive:@selector(timeUpdated)];
            [playback trigger:CLPPlaybackEventTimeUpdated];

            // param position, duration
            // this.trigger(Events.CONTAINER_TIMEUPDATE, position, duration, this.name);
        });

        it(@"should listen to playback's ready event", ^{
            [[container should] receive:@selector(ready)];
            [playback trigger:CLPPlaybackEventReady];

            // this.isReady = true;
            // this.trigger(Events.CONTAINER_READY, this.name);
        });

        it(@"should listen to playback's buffering event", ^{
            [[container should] receive:@selector(buffering)];
            [playback trigger:CLPPlaybackEventBuffering];

            // this.trigger(Events.CONTAINER_STATE_BUFFERING, this.name);
        });

        it(@"should listen to playback's buffer full event", ^{
            [[container should] receive:@selector(bufferFull)];
            [playback trigger:CLPPlaybackEventBufferFull];

            // this.trigger(Events.CONTAINER_STATE_BUFFERFULL, this.name);
        });

        it(@"should listen to playback's settings update event", ^{
            [[container should] receive:@selector(settingsUpdated)];
            [playback trigger:CLPPlaybackEventSettingsUdpdated];

            // this.settings = this.playback.settings;
            // this.trigger(Events.CONTAINER_SETTINGSUPDATE);
        });

        it(@"should listen to playback's loaded metadata event", ^{
            [[container should] receive:@selector(loadedMetadata)];
            [playback trigger:CLPPlaybackEventLoadedMetadata];

            // param duration
            // this.trigger(Events.CONTAINER_LOADEDMETADATA, duration);
        });

        it(@"should listen to playback's HD update event", ^{
            [[container should] receive:@selector(highDefinitionUpdated)];
            [playback trigger:CLPPlaybackEventHighDefinitionUpdate];

            // this.trigger(Events.CONTAINER_HIGHDEFINITIONUPDATES);
        });

        it(@"should listen to playback's bit rate event", ^{
            [[container should] receive:@selector(updateBitrate)];
            [playback trigger:CLPPlaybackEventBitRate];

            // param newBitrate
            // this.trigger(Events.CONTAINER_BITRATE, newBitrate)
        });

        it(@"should listen to playback's state changed event", ^{
            [[container should] receive:@selector(stateChanged)];
            [playback trigger:CLPPlaybackEventStateChanged];

            // this.trigger(Events.CONTAINER_PLAYBACKSTATE);
        });

        it(@"should listen to playback's DVR state changed event", ^{
            [[container should] receive:@selector(dvrStateChanged)];
            [playback trigger:CLPPlaybackEventDVRStateChanged];

            // param dvrInUse
            // this.settings = this.playback.settings
            // this.dvrInUse = dvrInUse
            // this.trigger(Events.CONTAINER_PLAYBACKDVRSTATECHANGED, dvrInUse)
        });

        it(@"should listen to playback's disable media control event", ^{
            [[container should] receive:@selector(disableMediaControl)];
            [playback trigger:CLPPlaybackEventMediaControlDisabled];

            // this.mediaControlDisabled = true;
            // this.trigger(Events.CONTAINER_MEDIACONTROL_DISABLE);
        });

        it(@"should listen to playback's enable media control event", ^{
            [[container should] receive:@selector(enableMediaControl)];
            [playback trigger:CLPPlaybackEventMediaControlEnabled];

            // this.mediaControlDisabled = false;
            // this.trigger(Events.CONTAINER_MEDIACONTROL_ENABLE);
        });

        it(@"should listen to playback's end event", ^{
            [[container should] receive:@selector(ended)];
            [playback trigger:CLPPlaybackEventEnded];

            // this.trigger(Events.CONTAINER_ENDED, this, this.name);
        });

        it(@"should listen to playback's play event", ^{
            [[container should] receive:@selector(playing)];
            [playback trigger:CLPPlaybackEventPlay];

            // this.trigger(Events.CONTAINER_PLAY, this.name);
        });

        it(@"should listen to playback's error event", ^{
            [[container should] receive:@selector(error)];
            [playback trigger:CLPPlaybackEventError];

            // param errorObj
            // this.$el.append(errorObj.render().el)
            // this.trigger(Events.CONTAINER_ERROR, {error: errorObj, container: this}, this.name);
        });
    });
});

SPEC_END