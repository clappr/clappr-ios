//
//  AcceptanceTests.m
//  AcceptanceTests
//
//  Created by Gustavo Barbosa on 1/26/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>
#import <KIF-Kiwi/KIF-Kiwi.h>

SPEC_BEGIN(MainViewAppSpec)

describe(@"Main view", ^{

    it(@"should have tappable view", ^{
        [tester tapViewWithAccessibilityLabel:@"Media Control"];
    });

});

SPEC_END