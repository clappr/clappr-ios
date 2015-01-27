//
//  CLPUIObject.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/10/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPUIObject.h"

@implementation CLPUIObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _view = [UIView new];
    }
    return self;
}

- (instancetype)render
{
    return self;
}

- (instancetype)remove
{
    [_view removeFromSuperview];
    return self;
}

@end
