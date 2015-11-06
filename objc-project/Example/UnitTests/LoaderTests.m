#import <Clappr/Clappr.h>

SPEC_BEGIN(Loader)

describe(@"Loader", ^{

    describe(@"playback plugins", ^{

        it(@"should contain the AVFoundation playback as a default plugin", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];
            BOOL containsPlugin = [loader containsPlugin:[CLPAVFoundationPlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should look into playback plugins if I'm searching for a playback plugin", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(playbackPlugins) andReturn:@[[FakePlaybackPlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackPlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should only match plugin subclass", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(playbackPlugins) andReturn:@[[CLPPlayback class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(playbackPlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });

    describe(@"container plugins", ^{

        it(@"should look into container plugins if I'm searching for a container plugin", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(containerPlugins) andReturn:@[[FakeUIContainerPlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakeUIContainerPlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(containerPlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakeUIContainerPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });

    describe(@"core plugins", ^{

        it(@"should look into core plugins if I'm searching for a core plugin", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(corePlugins) andReturn:@[[FakeUICorePlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakeUICorePlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedLoader];

            [loader stub:@selector(corePlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakeUICorePlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });
});

SPEC_END
