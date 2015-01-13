//
//  CLPCore.m
//  Clappr
//
//  Created by Gustavo Barbosa on 1/12/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import "CLPCore.h"

#import "CLPContainer.h"
#import "CLPPlayback.h"

@interface CLPCore ()
{
    NSMutableArray *containers;
}
@end


@implementation CLPCore

- (instancetype)initWithSources:(NSArray *)sources
{
    self = [super init];
    if (self) {
        _sources = sources;
        [self createContainers];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithSources: instead"
                                 userInfo:nil];
}

- (void)createContainers
{
    containers = [@[] mutableCopy];

    for (id source in _sources) {

        NSURL *sourceURL;
        if ([source isKindOfClass:[NSString class]])
            sourceURL = [NSURL URLWithString:source];
        else if ([source isKindOfClass:[NSURL class]])
            sourceURL = source;

        if (!sourceURL)
            continue;

        CLPPlayback *playback = [[CLPPlayback alloc] initWithURL:sourceURL];
        CLPContainer *container = [[CLPContainer alloc] initWithPlayback:playback];
        [containers addObject:container];
    }
}

#pragma mark - Accessors

- (NSArray *)containers
{
    return [containers copy];
}

@end
