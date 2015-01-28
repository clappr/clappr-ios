#import <Clappr/Clappr.h>

SPEC_BEGIN(PlayerSpec)

describe(@"Player", ^{

    it(@"can be instantiated passing a source URL", ^{
        NSURL *sourceURL = [NSURL URLWithString:@"http://www.somesite.com/somevideo.mp4"];
        CLPPlayer *player = [[CLPPlayer alloc] initWithSourceURL:sourceURL];

        CLPContainer *mainContainer = player.core.containers.firstObject;
        [[mainContainer.playback.url should] equal:sourceURL];
    });

    it(@"can be instantiated passing an array of URLS", ^{
        NSURL *firstSource = [NSURL URLWithString:@"http://www.site1.com/video.mp4"];
        NSURL *secondsSource = [NSURL URLWithString:@"http://www.site2.com/video.mp4"];
        NSURL *thirdSource = [NSURL URLWithString:@"http://www.site3.com/video.mp4"];
        CLPPlayer *player = [[CLPPlayer alloc] initWithSourcesURLs:@[firstSource, secondsSource, thirdSource]];

        [[player.core.containers should] haveCountOf:3];

        [[[player.core.containers[0] playback].url should] equal:firstSource];
        [[[player.core.containers[1] playback].url should] equal:secondsSource];
        [[[player.core.containers[2] playback].url should] equal:thirdSource];
    });

});

SPEC_END