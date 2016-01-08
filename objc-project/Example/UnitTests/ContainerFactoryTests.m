#import <Clappr/Clappr.h>

@interface FakeContainerPlugin: CLPUIContainerPlugin
@end

@implementation FakeContainerPlugin
@end

@interface DummyContainerPlugin: CLPUIContainerPlugin
@end

@implementation DummyContainerPlugin
@end

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

        it(@"should add all container plugins from loader", ^{
            NSArray *fakePlugins = @[[FakeContainerPlugin class], [DummyContainerPlugin class]];
            [loader stub:@selector(containerPlugins) andReturn:fakePlugins];

            NSArray *containers = [factory createContainers];

            CLPContainer *container = containers.firstObject;

            [[theValue([container hasPlugin:[FakeContainerPlugin class]]) should] beTrue];
            [[theValue([container hasPlugin:[DummyContainerPlugin class]]) should] beTrue];
        });
    });

});

SPEC_END
