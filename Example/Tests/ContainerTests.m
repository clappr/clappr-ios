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

    beforeEach(^{
        container = [CLPContainer new];
    });

    it(@"should have a default name", ^{
        [[container.name should] equal:@"Container"];
    });

    context(@"event binding", ^{

        pending(@"should listen to playback progress", ^{});

        pending(@"should listen to playback time updated", ^{});

        pending(@"should listen to playback ready", ^{});

        pending(@"should listen to playback buffering", ^{});

        pending(@"should listen to playback buffer full", ^{});

        pending(@"should listen to playback settings update", ^{});

        pending(@"should listen to playback loaded metadata", ^{});

        pending(@"should listen to playback high definition update", ^{});

        pending(@"should listen to playback bit rate", ^{});

        pending(@"should listen to playback state changed", ^{});

        pending(@"should listen to playback DVR state changed", ^{});

        pending(@"should listen to playback disable media control", ^{});

        pending(@"should listen to playback enable media control", ^{});

        pending(@"should listen to playback ended", ^{});

        pending(@"should listen to playback play", ^{});

        pending(@"should listen to playback error", ^{});
    });
});

SPEC_END