//
//  BaseObjectTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>


SPEC_BEGIN(BaseObject)

describe(@"BaseObject", ^{

    __block CLPBaseObject *baseObject;

    beforeEach(^{
        baseObject = [CLPBaseObject new];
    });

    it(@"should not raise an exception if its callback is nil", ^{
        [baseObject on:@"some-event" callback:nil];
        [[theBlock(^{ [baseObject trigger:@"some-event"]; }) shouldNot] raise];
    });

    describe(@"on", ^{

        __block BOOL callbackWasCalled;

        beforeEach(^{
            callbackWasCalled = NO;
        });

        it(@"callback should be called on event trigger", ^{
            [baseObject on:@"some-event" callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            [baseObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(YES)];
        });

        it(@"callback should be called for every callback registered", ^{
            [baseObject on:@"some-event" callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            __block BOOL anotherCallbackWasCalled = NO;
            [baseObject on:@"some-event" callback:^(NSDictionary *userInfo) {
                anotherCallbackWasCalled = YES;
            }];

            [baseObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(YES)];
            [[theValue(anotherCallbackWasCalled) should] equal:theValue(YES)];
        });

        it(@"callback should not be called for another event trigger", ^{
            [baseObject on:@"some-event" callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            [baseObject trigger:@"another-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(NO)];
        });

        it(@"callback should not be called for another context object", ^{
            CLPBaseObject *anotherObject = [CLPBaseObject new];
            [baseObject on:@"some-event" callback:^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            }];

            [anotherObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(NO)];
        });

        it(@"callback should not be called when handler is removed", ^{
            EventCallback callback = ^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            };

            [baseObject on:@"some-event" callback:callback];
            [baseObject off:@"some-event" callback:callback];

            [baseObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(NO)];
        });

        it(@"callback should not be called if removed, but the others should", ^{
            EventCallback callback = ^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            };

            __block BOOL anotherCallbackWasCalled = NO;
            EventCallback anotherCallback = ^(NSDictionary *userInfo) {
                anotherCallbackWasCalled = YES;
            };

            [baseObject on:@"some-event" callback:callback];
            [baseObject on:@"some-event" callback:anotherCallback];

            [baseObject off:@"some-event" callback:callback];

            [baseObject trigger:@"some-event"];
            
            [[theValue(callbackWasCalled) should] equal:theValue(NO)];
            [[theValue(anotherCallbackWasCalled) should] equal:theValue(YES)];
        });

    });

    describe(@"once", ^{

        it(@"callback should be called on event trigger", ^{
            __block BOOL callbackWasCalled = NO;
            EventCallback callback = ^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            };

            [baseObject once:@"some-event" callback:callback];

            [baseObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(YES)];
        });

        it(@"callback should not be called twice", ^{
            __block BOOL callbackWasCalled = NO;
            EventCallback callback = ^(NSDictionary *userInfo) {
                callbackWasCalled = YES;
            };

            [baseObject once:@"some-event" callback:callback];
            [baseObject trigger:@"some-event"];

            callbackWasCalled = NO;

            [baseObject trigger:@"some-event"];

            [[theValue(callbackWasCalled) should] equal:theValue(NO)];
        });
    });
});

SPEC_END
