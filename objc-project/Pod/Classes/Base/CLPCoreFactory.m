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

- (instancetype)initWithPlayer:(CLPPlayer *)player
{
    self = [super init];
    if (self) {
        _player = player;
    }

    return self;
}

- (CLPCore *)create
{
    CLPCore *core = [[CLPCore alloc] initWithSources:@[]];
    for (id plugin in [CLPLoader sharedLoader].corePlugins) {
        [core addPlugin:plugin];
    }
    return core;
}

@end
