#import <Clappr/Clappr.h>

SPEC_BEGIN(UIContainerPlugin)

describe(@"UIContainerPlugin", ^{

    __block CLPUIContainerPlugin *plugin;

    beforeEach(^{
        plugin = [CLPUIContainerPlugin new];
    });

    it(@"should be enabled by default when instantiated", ^{
        [[theValue(plugin.enabled) should] beTrue];
    });

    it(@"should show its view when calling setEnabled YES", ^{
        plugin.enabled = YES;
        [[theValue(plugin.view.hidden) should] beFalse];
    });

    it(@"should hide its view when calling setEnabled NO", ^{
        plugin.enabled = NO;
        [[theValue(plugin.view.hidden) should] beTrue];
    });

    it(@"should stop listening any event after disable", ^{
        __block BOOL callbackWasCalled = NO;
        [plugin on:@"some-event" callback:^(NSDictionary *userInfo) {
            callbackWasCalled = YES;
        }];

        plugin.enabled = NO;

        [plugin trigger:@"some-event"];

        [[theValue(callbackWasCalled) should] beFalse];
    });
});

SPEC_END
