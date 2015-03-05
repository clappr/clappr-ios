#import <Clappr/Clappr.h>

SPEC_BEGIN(PlayerSpec)

describe(@"Player", ^{

    it(@"can be instantiated passing a source URL", ^{
        NSURL *sourceURL = [NSURL URLWithString:@"http://www.somesite.com/somevideo.mp4"];
        CLPPlayer *player = [[CLPPlayer alloc] initWithSourceURL:sourceURL];

        CLPContainer *mainContainer = player.core.containers.firstObject;
        [[mainContainer.playback.url should] equal:sourceURL];
    });
});

SPEC_END