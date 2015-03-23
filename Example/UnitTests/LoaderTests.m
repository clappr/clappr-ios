#import <Clappr/Clappr.h>

@interface FakePlaybackLoaderPlugin : CLPPlayback
@end

@implementation FakePlaybackLoaderPlugin
@end

@interface FakeContainerLoaderPlugin : CLPContainer
@end

@implementation FakeContainerLoaderPlugin
@end

@interface FakeCoreLoaderPlugin : CLPCore
@end

@implementation FakeCoreLoaderPlugin
@end


SPEC_BEGIN(Loader)

describe(@"Loader", ^{

    describe(@"playback plugins", ^{

        it(@"should contain the AVFoundation playback as a default plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];
            BOOL containsPlugin = [loader containsPlugin:[CLPAVFoundationPlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should look into playback plugins if I'm searching for a playback plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(playbackPlugins) andReturn:@[[FakePlaybackLoaderPlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackLoaderPlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should only match plugin subclass", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(playbackPlugins) andReturn:@[[CLPPlayback class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackLoaderPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(playbackPlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakePlaybackLoaderPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });

    describe(@"container plugins", ^{

        it(@"should look into container plugins if I'm searching for a container plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(containerPlugins) andReturn:@[[FakeContainerLoaderPlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakeContainerLoaderPlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(containerPlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakeContainerLoaderPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });

    describe(@"core plugins", ^{
q
        it(@"should look into core plugins if I'm searching for a core plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(corePlugins) andReturn:@[[FakeCoreLoaderPlugin class]]];

            BOOL containsPlugin = [loader containsPlugin:[FakeCoreLoaderPlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should not match for an empty plugin list", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            [loader stub:@selector(corePlugins) andReturn:@[]];

            BOOL containsPlugin = [loader containsPlugin:[FakeCoreLoaderPlugin class]];
            [[theValue(containsPlugin) should] beFalse];
        });
    });
});

SPEC_END
