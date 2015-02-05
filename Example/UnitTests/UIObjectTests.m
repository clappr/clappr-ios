#import <Clappr/Clappr.h>

SPEC_BEGIN(UIObject)

describe(@"UIObject", ^{

    __block CLPUIObject *uiObject;

    beforeEach(^{
        uiObject = [CLPUIObject new];
    });

    it(@"should ensure a view is created when initialized", ^{
        [[uiObject.view shouldNot] beNil];
    });

    it(@"should be removed from its superview when call remove", ^{
        UIView *containerView = [UIView new];
        [containerView addSubview:uiObject.view];

        [[uiObject.view.superview should] equal:containerView];

        [uiObject remove];

        [[uiObject.view.superview should] beNil];
    });

    it(@"should stop listening events when call remove", ^{

        __block BOOL callbackWasCalled = NO;
        [uiObject on:@"some-event" callback:^(NSDictionary *userInfo) {
            callbackWasCalled = YES;
        }];

        [uiObject remove];

        [uiObject trigger:@"some-event"];

        [[theValue(callbackWasCalled) should] beFalse];
    });
});

SPEC_END