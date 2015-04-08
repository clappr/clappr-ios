#import <Clappr/Clappr.h>

SPEC_BEGIN(Core)

describe(@"Core", ^{

    describe(@"creation", ^{

        it(@"should have a designated initializer receiving an array of sources", ^{

            NSArray *sources = @[
                [NSURL URLWithString:@"http://my.awesomevideo.globo.com/123456"],
                [NSURL URLWithString:@"http://another.awesomevideo.globo.com/123456"]
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

    describe(@"containers", ^{

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

            // an array of strings, for example
            NSArray *sources = @[
                @"http://my.awesomevideo.globo.com/123456",
                @"http://my.awesomevideo.globo.com/123456"
            ];

            CLPCore *core = [[CLPCore alloc] initWithSources:sources];

            [[theValue(core.containers.count) should] equal:theValue(0)];
        });
    });

    describe(@"mediaControl", ^{

        __block CLPCore *core;
        const NSURL *source = [NSURL URLWithString:@"http://my.video.com/v.mp4"];

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

    describe(@"plugins", ^{

        __block CLPCore *core;
        __block FakeUICorePlugin *fakeCorePlugin;

        beforeEach(^{
            core = [[CLPCore alloc] initWithSources:@[]];
            fakeCorePlugin = [[FakeUICorePlugin alloc] initWithCore:core];
        });

        describe(@"addition", ^{

            it(@"should be able to add core plugins", ^{
                NSUInteger initialPluginsCount = core.plugins.count;

                [core addPlugin:fakeCorePlugin];

                [[core.plugins should] haveCountOf:initialPluginsCount+1];
            });

            it(@"should not be able to add another kind of plugin", ^{
                NSUInteger initialPluginsCount = core.plugins.count;

                FakeUIContainerPlugin *fakeContainerPlugin = [FakeUIContainerPlugin new];
                [core addPlugin:fakeContainerPlugin];

                [[core.plugins should] haveCountOf:initialPluginsCount];
            });

            context(@"ui plugin", ^{
                it(@"should be a subview of core's view", ^{
                    [core addPlugin:fakeCorePlugin];
                    [[fakeCorePlugin.view.superview should] equal:core.view];
                });
            });
        });

        describe(@"verification", ^{

            it(@"should return YES if a core plugin is installed", ^{
                [core addPlugin:fakeCorePlugin];

                BOOL containsPlugin = [core hasPlugin:[fakeCorePlugin class]];

                [[theValue(containsPlugin) should] beTrue];
            });

            it(@"should return NO if a core plugin is not installed", ^{
                FakeUIContainerPlugin *fakeContainerPlugin = [FakeUIContainerPlugin new];
                [core addPlugin:fakeContainerPlugin];

                BOOL containsPlugin = [core hasPlugin:[fakeContainerPlugin class]];

                [[theValue(containsPlugin) should] beFalse];
            });
        });

    });
});

SPEC_END