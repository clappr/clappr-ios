#import <Clappr/Clappr.h>

SPEC_BEGIN(UIContainerPlugin)

describe(@"UIContainerPlugin", ^{

    NSURL *sourceURL = [NSURL URLWithString:@"http://some.url.com/video.mp4"];
    CLPPlayback *playback = [[CLPPlayback alloc] initWithURL:sourceURL];
    CLPContainer *container = [[CLPContainer alloc] initWithPlayback:playback];

    describe(@"instantiation", ^{

        it(@"should have a designated initializer receiving a container", ^{
            CLPUIContainerPlugin *plugin = [[CLPUIContainerPlugin alloc] initWithContainer:container];
            [[plugin.container should] equal:container];
        });

        it(@"should raise an exception for its default initializer", ^{
            [[theBlock(^{
                [CLPUIContainerPlugin new];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });

        it(@"should enable the plugin by default", ^{
            CLPUIContainerPlugin *plugin = [[CLPUIContainerPlugin alloc] initWithContainer:container];
            [[theValue(plugin.enabled) should] beTrue];
        });
    });

    describe(@"enabling", ^{

        __block CLPUIContainerPlugin *plugin;

        beforeEach(^{
            plugin = [[CLPUIContainerPlugin alloc] initWithContainer:container];
            [plugin stub:NSSelectorFromString(@"isEnabled") andReturn:theValue(NO)];
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

        __block CLPUIContainerPlugin *plugin;

        beforeEach(^{
            plugin = [[CLPUIContainerPlugin alloc] initWithContainer:container];
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
