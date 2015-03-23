#import <Clappr/Clappr.h>

SPEC_BEGIN(ContainerFactory)

describe(@"ContainerFactory", ^{

    describe(@"instantiation", ^{

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPContainerFactory new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"shoud have a designated initializer with sources and the loader", ^{
            NSArray *sources = [NSArray array];
            CLPLoader *loader = [CLPLoader new];
            CLPContainerFactory *factory = [[CLPContainerFactory alloc] initWithSources:sources loader:loader];
            [[factory.sources should] equal:sources];
            [[factory.loader should] equal:loader];
        });
    });

    describe(@"container creation", ^{
        __block NSArray *sources;
        __block CLPLoader *loader;
        __block CLPContainerFactory *factory;

        beforeEach(^{
            NSURL *url = [NSURL URLWithString:@"http://test.com"];
            sources = @[url];

            loader = [CLPLoader new];
            factory = [[CLPContainerFactory alloc] initWithSources:sources loader:loader];
        });

        it(@"should create a container for each source", ^{
            NSArray *containers = [factory createContainers];

            [[theValue(containers.count) should] equal:theValue(sources.count)];
        });

        it(@"should use the default playback if it is the only one available", ^{
            [loader stub:@selector(playbackPlugins) andReturn:@[[CLPAVFoundationPlayback class]]];

            NSArray *containers = [factory createContainers];

            CLPContainer *container = containers.firstObject;
            [[container.playback.class should] equal:[CLPAVFoundationPlayback class]];
        });
    });

});

SPEC_END
