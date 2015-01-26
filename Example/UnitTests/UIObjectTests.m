//
//  UIObjectTests.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/10/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

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

    it(@"should return self when call render", ^{
        CLPUIObject *returnedObject = [uiObject render];
        [[returnedObject should] equal:uiObject];
    });

    it(@"should be removed from its superview when call remove", ^{
        UIView *containerView = [UIView new];
        [containerView addSubview:uiObject.view];

        [[uiObject.view.superview should] equal:containerView];

        [uiObject remove];

        [[uiObject.view.superview  should] beNil];
    });
});

SPEC_END