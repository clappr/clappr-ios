//
//  AcceptanceTests.m
//  AcceptanceTests
//
//  Created by Gustavo Barbosa on 1/26/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>
#import <KIF-Kiwi/KIF-Kiwi.h>

SPEC_BEGIN(MediaControlSpec)

describe(@"Media Control", ^{

    context(@"General", ^{
        it(@"should start with all its controls appearing", ^{

            [tester waitForTappableViewWithAccessibilityLabel:@"play/pause"];
            // [tester waitForTappableViewWithAccessibilityLabel:@"toggle fullscreen"];

            [tester waitForViewWithAccessibilityLabel:@"current time"];
            [tester waitForViewWithAccessibilityLabel:@"duration"];

            // [tester waitForViewWithAccessibilityLabel:@"scrubber"];
            // [tester waitForViewWithAccessibilityLabel:@"seek bar"];
        });
    });

    describe(@"Play", ^{

        __block UIButton *playPauseButton;

        beforeAll(^{
            playPauseButton = (UIButton *)[tester waitForTappableViewWithAccessibilityLabel:@"play/pause"];
        });

        it(@"should start as a play button", ^{
            [[theValue(playPauseButton.state) should] equal:theValue(UIControlStateNormal)];
            [[[playPauseButton titleForState:UIControlStateNormal] should] equal:@"\ue001"];
        });

        it(@"should change the play button to pause after play", ^{

            [tester tapViewWithAccessibilityLabel:playPauseButton.accessibilityLabel];

            [[theValue(playPauseButton.state) should] equal:theValue(UIControlStateSelected)];
            [[[playPauseButton titleForState:UIControlStateSelected] should] equal:@"\ue002"];
        });
    });

    describe(@"Duration", ^{

        __block UIButton *playPauseButton;
        __block UILabel *durationLabel;

        beforeAll(^{
            playPauseButton = (UIButton *)[tester waitForTappableViewWithAccessibilityLabel:@"play/pause"];
            durationLabel = (UILabel *)[tester waitForViewWithAccessibilityLabel:@"duration"];
        });

        it(@"should have a initial value of 00:00", ^{
            [[durationLabel.text should] equal:@"00:00"];
        });

        it(@"should be update after load the playback", ^{

        });
    });
});

SPEC_END