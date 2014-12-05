//
//  CLPBaseObject.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPBaseObject.h"


@interface CLPBaseObject ()
{
    NSMutableDictionary *eventHandlers;
}
@end

@implementation CLPBaseObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        eventHandlers = [@{} mutableCopy];
    }
    return self;
}

- (void)on:(NSString *)eventName callback:(EventCallback)callback
{
    if (!callback)
        return;

    if (!eventHandlers[eventName])
        eventHandlers[eventName] = [@[] mutableCopy];

    [eventHandlers[eventName] addObject:callback];
}

- (void)off:(NSString *)eventName callback:(EventCallback)callback
{
    if (!callback)
        return;

    for (EventCallback c in eventHandlers[eventName]) {
        if (c == callback)
            [eventHandlers[eventName] removeObject:callback];
    }
}

- (void)trigger:(NSString *)eventName
{
    for (EventCallback callback in eventHandlers[eventName]) {
        callback(@{});
    }
}

@end
