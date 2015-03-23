#import "CLPCoreFactory.h"
#import "CLPPlayer.h"
#import "CLPLoader.h"

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
    return nil;
}

@end
