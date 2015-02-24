#import <Clappr/Clappr.h>

@interface MockCorePlugin : CLPUICorePlugin
@property (nonatomic, assign) BOOL bindEventsWasCalled;
@end

@implementation MockCorePlugin
- (void)bindEvents
{
    _bindEventsWasCalled = YES;
}
@end

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

        it(@"should enabled the plugin by default", ^{
            CLPUICorePlugin *plugin = [[CLPUICorePlugin alloc] initWithCore:core];
            [[theValue(plugin.enabled) should] beTrue];
        });

        it(@"should have its view as a child of core's view", ^{
            CLPUICorePlugin *plugin = [[CLPUICorePlugin alloc] initWithCore:core];
            [[plugin.view.superview should] equal:core.view];
        });

        it(@"should call bindEvents", ^{
            MockCorePlugin *plugin = [[MockCorePlugin alloc] initWithCore:core];
            [[theValue(plugin.bindEventsWasCalled) should] beTrue];
        });
    });

    describe(@"enabling", ^{

        __block CLPUICorePlugin *plugin;

        beforeEach(^{
            plugin = [[CLPUICorePlugin alloc] initWithCore:core];
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(NO)];
        });

        it(@"should call bindEvents", ^{
            [[plugin should] receive:NSSelectorFromString(@"bindEvents")];
            plugin.enabled = YES;
        });

        it(@"should not be hidden", ^{
            plugin.view.hidden = YES;
            plugin.enabled = YES;
            [[theValue(plugin.view.hidden) shouldNot] beTrue];
        });

        it(@"should not bind events again if already enabled", ^{
            [[plugin should] receive:NSSelectorFromString(@"bindEvents") withCount:1];
            plugin.enabled = YES;
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(YES)];
            plugin.enabled = YES;
        });
    });

    describe(@"disabling", ^{

        CLPUICorePlugin *plugin = [[CLPUICorePlugin alloc] initWithCore:core];

        it(@"should stop listening to events", ^{
            __block BOOL eventWasCaught = NO;
            [plugin on:@"some-event" callback:^(NSDictionary *userInfo) {
                eventWasCaught = YES;
            }];

            plugin.enabled = NO;

            [plugin trigger:@"some-event"];

            [[theValue(eventWasCaught) should] beFalse];
        });

        it(@"should be hidden", ^{
            plugin.enabled = NO;
            [[theValue(plugin.view.hidden) should] beTrue];
        });
    });
});

SPEC_END
