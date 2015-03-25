#import <Clappr/Clappr.h>

SPEC_BEGIN(CoreFactory)

describe(@"CoreFactory", ^{

    __block CLPPlayer *player;
    __block CLPLoader *loader;

    beforeEach(^{
        player = [CLPPlayer new];
        loader = [CLPLoader new];
    });

    describe(@"instantiation", ^{

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPCoreFactory new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"shoud have a designated initializer receiving the player and the loader", ^{

            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player loader:loader];

            [[factory.player should] equal:player];
            [[factory.loader should] equal:loader];
        });
    });

    describe(@"core creation", ^{

        it(@"should be able to create a container using its create method", ^{
            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player loader:loader];
            CLPCore *core = [factory create];
            [[core shouldNot] beNil];
        });

        pending(@"should be able to create a container with plugins from loader", ^{

            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player loader:loader];
            [loader stub:@selector(corePlugins) andReturn:@[[FakeUICorePlugin class]]];

            CLPCore *core = [factory create];

            BOOL containsPlugin = [core hasPlugin:[FakeUICorePlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

});

SPEC_END
