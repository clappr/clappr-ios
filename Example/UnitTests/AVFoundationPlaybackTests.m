#import <Clappr/Clappr.h>
#import <AVFoundation/AVFoundation.h>

SPEC_BEGIN(AVFoundationPlayback)

describe(@"AVFoundationPlayback", ^{

    describe(@"controls", ^{

        __block CLPAVFoundationPlayback *playback;
        __block AVPlayer *avPlayer;

        beforeEach(^{
            NSURL *url = [NSURL URLWithString:@""];
            playback = [[CLPAVFoundationPlayback alloc] initWithURL:url];
            avPlayer = [playback valueForKey:@"_avPlayer"];
        });

        describe(@"play", ^{
            it(@"should call avplayer play method for its play", ^{
                [[avPlayer should] receive:@selector(play)];
                [playback play];
            });
        });

        describe(@"pause", ^{
            it(@"should call avplayer pause method for its pause", ^{
                [[avPlayer should] receive:@selector(pause)];
                [playback pause];
            });
        });

        describe(@"is playing", ^{

            it(@"should return true if avplayer's rate is positive", ^{
                [avPlayer stub:@selector(rate) andReturn:theValue(23.0)];
                [[theValue([playback isPlaying]) should] beTrue];
            });

            it(@"should return false if avplayer's rate is zero", ^{
                [avPlayer stub:@selector(rate) andReturn:theValue(0.0)];
                [[theValue([playback isPlaying]) should] beFalse];
            });
        });

    });
});

SPEC_END
