//
//  CLPCallback.m
//  Pods
//
//  Created by Gustavo Barbosa on 12/4/14.
//
//

#import "CLPCallback.h"

@implementation CLPCallback

- (instancetype)initWithTarget:(id)target selector:(SEL)selector
{
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
    }
    return self;
}

+ (instancetype)callbackWithTarget:(id)target selector:(SEL)selector
{
    return [[CLPCallback alloc] initWithTarget:target selector:selector];
}

- (BOOL)isEqualToCallback:(CLPCallback *)callback
{
    if (callback == nil)
        return NO;

    if (self == callback)
        return YES;

    return _target == callback.target && _selector == callback.selector;
}

- (void)execute
{
    [_target performSelector:_selector];
}

@end
