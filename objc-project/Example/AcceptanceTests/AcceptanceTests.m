#import <Clappr/Clappr.h>
#import <KIF-Kiwi/KIF-Kiwi.h>

static NSString *const kSourceURLString = @"https://github.com/globocom/clappr-website/raw/gh-pages/highline.mp4";

void resetPlayer()
{
    [tester clearTextFromAndThenEnterText:kSourceURLString intoViewWithAccessibilityLabel:@"source url"];
    [tester tapViewWithAccessibilityLabel:@"load button"];
}

SPEC_BEGIN(MediaControlSpec)

describe(@"Media Control", ^{

    describe(@"Play", ^{

        __block UIButton *playPauseButton;

        beforeAll(^{
            resetPlayer();
            playPauseButton = (UIButton *)[tester waitForTappableViewWithAccessibilityLabel:@"play/pause"];
        });

        it(@"should start as a play button", ^{
            [[theValue(playPauseButton.state) should] equal:theValue(UIControlStateNormal)];
            [[[playPauseButton titleForState:UIControlStateNormal] should] equal:@"\ue001"];
        });

        it(@"should change the play button to pause after play", ^{

            [tester tapViewWithAccessibilityLabel:playPauseButton.accessibilityLabel];

            [tester waitForAnimationsToFinish];

            [[theValue(playPauseButton.state) should] equal:theValue(UIControlStateSelected)];
            [[[playPauseButton titleForState:UIControlStateSelected] should] equal:@"\ue002"];
        });
    });

    describe(@"Duration", ^{

        __block UIButton *playPauseButton;
        __block UILabel *durationLabel;

        beforeAll(^{
            resetPlayer();
            playPauseButton = (UIButton *)[tester waitForTappableViewWithAccessibilityLabel:@"play/pause"];
            durationLabel = (UILabel *)[tester waitForViewWithAccessibilityLabel:@"duration"];
        });

        it(@"should have a initial value of 00:00", ^{
            [[durationLabel.text should] equal:@"00:00"];
        });

        pending(@"should be update after load the playback", ^{

        });
    });

    describe(@"Visibility", ^{

        NSArray *controlNames = @[@"play/pause", @"current time", @"duration", @"scrubber", @"seek bar" /*, @"toggle fullscreen"*/];

        beforeEach(^{
            resetPlayer();
        });

        it(@"should start with all its controls appearing", ^{
            [controlNames enumerateObjectsUsingBlock:^(NSString *accessibilityLabel, NSUInteger idx, BOOL *stop) {
                [tester waitForViewWithAccessibilityLabel:accessibilityLabel];
            }];
        });

        it(@"should be hidden after touch an area without button", ^{

            [tester tapScreenAtPoint:CGPointMake(10, 10)];

            [controlNames enumerateObjectsUsingBlock:^(NSString *accessibilityLabel, NSUInteger idx, BOOL *stop) {
                [tester waitForAbsenceOfViewWithAccessibilityLabel:accessibilityLabel];
            }];
        });

        it(@"should be hidden after sometime when playback is playing", ^{

            [tester tapViewWithAccessibilityLabel:@"play/pause"];

            [tester waitForAnimationsToFinish];

            [tester waitForTimeInterval:3.0];

            [controlNames enumerateObjectsUsingBlock:^(NSString *accessibilityLabel, NSUInteger idx, BOOL *stop) {
                [tester waitForAbsenceOfViewWithAccessibilityLabel:accessibilityLabel];
            }];
        });
    });
});

SPEC_END