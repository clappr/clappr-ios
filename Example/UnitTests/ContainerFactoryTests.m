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
        it(@"should create a container for each source", ^{
            NSURL *url1 = [NSURL URLWithString:@"http://test1.com"];
            NSURL *url2 = [NSURL URLWithString:@"http://test2.com"];
            NSArray *sources = @[url1, url2];

            CLPLoader *loader = [CLPLoader new];
            CLPContainerFactory *factory = [[CLPContainerFactory alloc] initWithSources:sources loader:loader];

            NSArray *containers = [factory createContainers];

            [[theValue(containers.count) should] equal:theValue(sources.count)];
        });
    });

});

SPEC_END
