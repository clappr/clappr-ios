#import <Clappr/Clappr.h>

@interface FakePlaybackPlugin : CLPPlayback
@end

@implementation FakePlaybackPlugin
@end

SPEC_BEGIN(Loader)

describe(@"Loader", ^{

    describe(@"playback plugins", ^{

        it(@"should contain the AVFoundation playback as a default plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];
            BOOL containsPlugin = [loader containsPlugin:[CLPAVFoundationPlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });

        it(@"should look into playback plugins if I'm searching for a playback plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            NSArray *installedPlugins = [loader valueForKey:@"_playbackPlugins"];
            NSArray *plugins = [installedPlugins arrayByAddingObject:[FakePlayback class]];
            [loader setValue:plugins forKey:@"_playbackPlugins"];

            BOOL containsPlugin = [loader containsPlugin:[FakePlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

    xdescribe(@"container plugins", ^{

        it(@"should look into container plugins if I'm searching for a container plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            NSArray *installedPlugins = [loader valueForKey:@"_playbackPlugins"];
            NSArray *plugins = [installedPlugins arrayByAddingObject:[FakePlayback class]];
            [loader setValue:plugins forKey:@"_playbackPlugins"];

            BOOL containsPlugin = [loader containsPlugin:[FakePlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

    xdescribe(@"core plugins", ^{

        xit(@"should look into playback plugins if I'm searching for a playback plugin", ^{
            CLPLoader *loader = [CLPLoader sharedInstance];

            NSArray *installedPlugins = [loader valueForKey:@"_playbackPlugins"];
            NSArray *plugins = [installedPlugins arrayByAddingObject:[FakePlayback class]];
            [loader setValue:plugins forKey:@"_playbackPlugins"];

            BOOL containsPlugin = [loader containsPlugin:[FakePlayback class]];
            [[theValue(containsPlugin) should] beTrue];
        });
    });

});

SPEC_END
