//
//  BaseObjectTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>

@interface DummyObject : NSObject
@property (nonatomic, assign) BOOL methodWasCalled;
- (void)dummy;
@end

@implementation DummyObject
- (void)dummy { _methodWasCalled = YES; }
@end


SPEC_BEGIN(BaseObject)

describe(@"Callback", ^{

    __block CLPBaseObject *baseObject;
    __block DummyObject *dummyObject;
    __block CLPCallback *callback;

    beforeEach(^{
        baseObject = [CLPBaseObject new];

        dummyObject = [DummyObject new];
        callback = [CLPCallback callbackWithTarget:dummyObject selector:@selector(dummy)];
    });

    it(@"should be called on event trigger", ^{
        [baseObject on:@"some-event" callback:callback];
        [baseObject trigger:@"some-event"];

        [[theValue(dummyObject.methodWasCalled) should] equal:theValue(YES)];
    });

    it(@"should be called for every callback registered", ^{
        [baseObject on:@"some-event" callback:callback];

        DummyObject *anotherDummyObject = [DummyObject new];
        CLPCallback *anotherCallback = [CLPCallback callbackWithTarget:anotherDummyObject
                                                              selector:@selector(dummy)];
        [baseObject on:@"some-event" callback:anotherCallback];

        [baseObject trigger:@"some-event"];

        [[theValue(dummyObject.methodWasCalled) should] equal:theValue(YES)];
        [[theValue(anotherDummyObject.methodWasCalled) should] equal:theValue(YES)];
    });

    it(@"should not raise an exception if it is nil", ^{
        [baseObject on:@"some-event" callback:nil];

        [[theBlock(^{ [baseObject trigger:@"some-event"]; }) shouldNot] raise];
    });

    it(@"should not be called for another event trigger", ^{
        [baseObject on:@"some-event" callback:callback];
        [baseObject trigger:@"another-event"];

        [[theValue(dummyObject.methodWasCalled) should] equal:theValue(NO)];
    });

    it(@"should not be called for another context object", ^{
        CLPBaseObject *anotherObject = [CLPBaseObject new];
        [baseObject on:@"some-event" callback:callback];
        [anotherObject trigger:@"some-event"];

        [[theValue(dummyObject.methodWasCalled) should] equal:theValue(NO)];
    });

    it(@"should not be called when handler is removed", ^{
        [baseObject on:@"some-event" callback:callback];
        [baseObject off:@"some-event" callback:callback];
        [baseObject trigger:@"some-event"];

        [[theValue(dummyObject.methodWasCalled) should] equal:theValue(NO)];
    });

    pending(@"should not be called if removed, but the others should", ^{});
});

SPEC_END
