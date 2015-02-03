#import <Clappr/Clappr.h>

SPEC_BEGIN(Loader)

describe(@"Loader", ^{

    describe(@"Playback Plugins", ^{

        it(@"should contain the AVFoundation playback as a default plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];
            BOOL containsPlugin = [loader containsPlugin:[CLPAVFoundationPlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

});

SPEC_END
