#import <Clappr/Clappr.h>

SPEC_BEGIN(CoreFactory)

describe(@"CoreFactory", ^{

    __block CLPPlayer *player;

    beforeEach(^{
        player = [CLPPlayer new];
    });

    describe(@"instantiation", ^{

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPCoreFactory new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"shoud have a designated initializer receiving the player", ^{

            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player];

            [[factory.player should] equal:player];
        });
    });

    describe(@"core creation", ^{

        it(@"should be able to create a container using its create method", ^{
            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player];
            CLPCore *core = [factory create];
            [[core shouldNot] beNil];
        });

        it(@"should be able to create a container with plugins from loader", ^{

            CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:player];
            [[CLPLoader sharedLoader] stub:@selector(corePlugins) andReturn:@[[FakeUICorePlugin class]]];

            CLPCore *core = [factory create];

            BOOL containsPlugin = [core hasPlugin:[FakeUICorePlugin class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

});

SPEC_END
