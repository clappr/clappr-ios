#import <Clappr/Clappr.h>

SPEC_BEGIN(UICorePlugin)

describe(@"UICorePlugin", ^{

    CLPCore *core = [[CLPCore alloc] initWithSources:@[]];;

    describe(@"instantiation", ^{

        it(@"should have a designated initializer receiving the core instance", ^{
            CLPUICorePlugin *plugin = [[CLPUICorePlugin alloc] initWithCore:core];
            [[plugin.core should] equal:core];
        });

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPUICorePlugin new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"should have its view as a child of core's view", ^{
            CLPUICorePlugin *plugin = [[CLPUICorePlugin alloc] initWithCore:core];
            [[plugin.superview should] equal:core];
        });
    });

});

SPEC_END
