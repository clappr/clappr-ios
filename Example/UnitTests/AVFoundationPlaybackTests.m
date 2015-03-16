#import <Clappr/Clappr.h>
#import <AVFoundation/AVFoundation.h>

SPEC_BEGIN(AVFoundationPlayback)

describe(@"AVFoundationPlayback", ^{

    describe(@"controls", ^{

        __block CLPAVFoundationPlayback *playback;

        beforeEach(^{
            NSURL *url = [NSURL URLWithString:@""];
            playback = [[CLPAVFoundationPlayback alloc] initWithURL:url];
        });

        it(@"should call avplayer play method for its play", ^{
            AVPlayer *avPlayer = [playback valueForKey:@"_avPlayer"];
            [[avPlayer should] receive:@selector(play)];
            [playback play];
        });

        it(@"should call avplayer pause method for its pause", ^{
            AVPlayer *avPlayer = [playback valueForKey:@"_avPlayer"];
            [[avPlayer should] receive:@selector(pause)];
            [playback pause];
        });
    });
});

SPEC_END
