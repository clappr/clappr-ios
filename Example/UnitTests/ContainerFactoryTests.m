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
});

SPEC_END
