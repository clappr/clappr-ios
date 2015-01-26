//
//  CoreTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 1/12/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>
#import <objc/runtime.h>

SPEC_BEGIN(Core)

describe(@"Core", ^{

    describe(@"Creation", ^{

        it(@"should have a designated initializer receiving an array of sources", ^{

            NSArray *sources = @[
                @"http://my.awesomevideo.globo.com/123456",
                @"http://another.awesomevideo.globo.com/123456"
            ];
            CLPCore *core = [[CLPCore alloc] initWithSources:sources];

            [[core.sources[0] should] equal:sources[0]];
            [[core.sources[1] should] equal:sources[1]];
        });

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPCore new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });
    });

    describe(@"Containers", ^{

        it(@"should be created given an array of sources as strings", ^{

            NSArray *sources = @[
                                 @"http://my.awesomevideo.globo.com/123456",
                                 @"http://another.awesomevideo.globo.com/123456"
                                 ];

            CLPCore *core = [[CLPCore alloc] initWithSources:sources];

            [[theValue(core.containers.count) should] equal:theValue(2)];

            CLPContainer *firstContainer = core.containers[0];
            [[firstContainer.playback.url.absoluteString should] equal:sources[0]];

            CLPContainer *secondContainer = core.containers[1];
            [[secondContainer.playback.url.absoluteString should] equal:sources[1]];
        });

        it(@"should be created given an array of sources as urls", ^{

            NSArray *sources = @[
                                 [NSURL URLWithString:@"http://my.awesomevideo.globo.com/123456"],
                                 [NSURL URLWithString:@"http://another.awesomevideo.globo.com/123456"]
                                 ];

            CLPCore *core = [[CLPCore alloc] initWithSources:sources];

            [[theValue(core.containers.count) should] equal:theValue(2)];

            CLPContainer *firstContainer = core.containers[0];
            [[firstContainer.playback.url should] equal:sources[0]];

            CLPContainer *secondContainer = core.containers[1];
            [[secondContainer.playback.url should] equal:sources[1]];
        });

        it(@"should not be created given an array of anything else", ^{

            NSArray *sources = @[ @{}, @123 ];

            CLPCore *core = [[CLPCore alloc] initWithSources:sources];

            [[theValue(core.containers.count) should] equal:theValue(0)];
        });
    });

    describe(@"MediaControl", ^{

        __block CLPCore *core;
        const NSString *source = @"http://my.video.com/v.mp4";

        beforeEach(^{
            core = [[CLPCore alloc] initWithSources:@[source]];
        });

        it(@"should be created in the top most container", ^{

            [[core.mediaControl shouldNot] beNil];

            CLPContainer *topMostContainer = [core.containers firstObject];
            [[core.mediaControl.container should] equal:topMostContainer];
        });

        it(@"should be visible by default", ^{
            [[theValue(core.mediaControl.view.hidden) should] beFalse];
        });

    });
});

SPEC_END