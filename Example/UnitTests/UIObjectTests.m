#import <Clappr/Clappr.h>

SPEC_BEGIN(UIObject)

describe(@"UIObject", ^{

    __block CLPUIObject *uiObject;

    beforeEach(^{
        uiObject = [CLPUIObject new];
    });

    it(@"should ensure a view is created when initialized", ^{
        [[uiObject shouldNot] beNil];
    });
});

SPEC_END