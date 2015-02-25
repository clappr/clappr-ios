#import <Clappr/Clappr.h>

SPEC_BEGIN(UIPlugin)

describe(@"UIPlugin", ^{

    describe(@"instantiation", ^{

        it(@"should enable the plugin by default", ^{
            CLPUIPlugin *plugin = [CLPUIPlugin new];
            [[theValue(plugin.enabled) should] beTrue];
        });
    });

    describe(@"enabling", ^{

        __block CLPUIPlugin *plugin;

        beforeEach(^{
            plugin = [CLPUIPlugin new];
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(NO)];
        });

        it(@"should call bindEvents", ^{
            [[plugin should] receive:NSSelectorFromString(@"bindEvents")];
            plugin.enabled = YES;
        });

        it(@"should not be hidden", ^{
            plugin.enabled = YES;
            [[theValue(plugin.view.hidden) should] beFalse];
        });

        it(@"should not bind events again if already enabled", ^{
            [[plugin should] receive:NSSelectorFromString(@"bindEvents") withCount:1];
            plugin.enabled = YES;
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(YES)];
            plugin.enabled = YES;
        });
    });

    describe(@"disabling", ^{

        __block CLPUIPlugin *plugin;

        beforeEach(^{
            plugin = [CLPUIPlugin new];
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(NO)];
        });

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
