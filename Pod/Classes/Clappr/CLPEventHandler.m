//
//  CLPEventHandler.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/9/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPEventHandler.h"

@implementation CLPEventHandler
{
    EventCallback _callback;
}

- (instancetype)initWithCallback:(EventCallback)callback
{
    self = [super init];
    if (self) {
        _callback = callback;
    }
    return self;
}

- (void)handleEvent
{
    if (_callback)
        _callback(@{});
}

@end
