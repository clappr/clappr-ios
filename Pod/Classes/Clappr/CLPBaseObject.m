//
//  CLPBaseObject.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPBaseObject.h"


@interface CLPBaseObject ()

@property (nonatomic, strong) NSMutableDictionary *eventHandlers;

@end

@implementation CLPBaseObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventHandlers = [@{} mutableCopy];
    }
    return self;
}

- (void)on:(NSString *)eventName callback:(EventCallback)callback
{
    if (!callback)
        return;

    [self addEventHandler:callback forEventName:eventName];
}

- (void)addEventHandler:(EventCallback)callback forEventName:(NSString *)eventName
{
    if (!_eventHandlers[eventName])
        _eventHandlers[eventName] = [@[] mutableCopy];

    [_eventHandlers[eventName] addObject:callback];
}

- (void)once:(NSString *)eventName callback:(EventCallback)callback
{
    __weak typeof(self) weakSelf = self;
    __weak __block EventCallback blockSelf;

    EventCallback wrapperCallback = [^(NSDictionary *userInfo) {
        if (callback)
            callback(userInfo);

        [weakSelf off:eventName callback:blockSelf];
    } copy];

    blockSelf = wrapperCallback;

    [self on:eventName callback:wrapperCallback];
}

- (void)off:(NSString *)eventName callback:(EventCallback)callback
{
    if (!callback)
        return;

    [self removeEventHandler:callback forEventName:eventName];
}

- (void)removeEventHandler:(EventCallback)callback forEventName:(NSString *)eventName
{
    BOOL callbackWasFound = NO;
    for (EventCallback c in _eventHandlers[eventName]) {
        if (c == callback) {
            callbackWasFound = YES;
            break;
        }
    }

    if (callbackWasFound)
        [_eventHandlers[eventName] removeObject:callback];
}

- (void)trigger:(NSString *)eventName
{
    for (EventCallback callback in _eventHandlers[eventName]) {
        callback(@{});
    }
}

- (void)listenTo:(CLPBaseObject *)contextObject
       eventName:(NSString *)eventName
        callback:(EventCallback)callback
{
    [contextObject addEventHandler:callback forEventName:eventName];
}

- (void)stopListening
{
    [_eventHandlers removeAllObjects];
}

- (void)stopListening:(CLPBaseObject *)contextObject
            eventName:(NSString *)eventName
             callback:(EventCallback)callback
{
    [contextObject removeEventHandler:callback forEventName:eventName];
}

@end
