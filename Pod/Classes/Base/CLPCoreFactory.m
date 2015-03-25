#import "CLPCoreFactory.h"
#import "CLPPlayer.h"
#import "CLPLoader.h"
#import "CLPCore.h"

@implementation CLPCoreFactory

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"use initWithPlayer:loader: instead"
                                 userInfo:nil];
}

- (instancetype)initWithPlayer:(CLPPlayer *)player loader:(CLPLoader *)loader
{
    self = [super init];
    if (self) {
        _player = player;
        _loader = loader;
    }

    return self;
}

- (CLPCore *)create
{
    CLPCore *core = [[CLPCore alloc] initWithSources:@[]];
    for (id plugin in _loader.corePlugins) {
        [core addPlugin:plugin];
    }
    return core;
}

@end
