#import <Clappr/Clappr.h>

SPEC_BEGIN(PlayerSpec)

describe(@"Player", ^{

    describe(@"instantiation", ^{

        it(@"can be instantiated passing a source URL", ^{
            NSURL *sourceURL = [NSURL URLWithString:@"http://www.somesite.com/somevideo.mp4"];
            CLPPlayer *player = [[CLPPlayer alloc] initWithSourceURL:sourceURL];

            CLPContainer *mainContainer = player.core.containers.firstObject;
            [[mainContainer.playback.url should] equal:sourceURL];
        });

        it(@"can be instantiated without sources. its not common, but it is ok", ^{
            CLPPlayer *player = [[CLPPlayer alloc] init];
            [[player.core.containers should] equal:@[]];
        });
    });

    describe(@"source", ^{

        it(@"should load sources in core after set source url", ^{

            NSURL *sourceURL = [NSURL URLWithString:@"http://www.somesite.com/somevideo.mp4"];

            CLPPlayer *player = [CLPPlayer new];

            [[player.core should] receive:@selector(loadSources:) withArguments:@[sourceURL]];
            player.sourceURL = sourceURL;
        });
    });
});

SPEC_END