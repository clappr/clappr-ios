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
    });
});

SPEC_END
