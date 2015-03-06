#import "CLPContainerFactory.h"
#import "CLPContainer.h"
#import "CLPLoader.h"

@implementation CLPContainerFactory

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"use initWithSources:loader: instead"
                                 userInfo:nil];
}

- (instancetype)initWithSources:(NSArray *)sources loader:(CLPLoader *)loader
{
    self = [super init];
    if (self) {
        _sources = [sources copy];
        _loader = loader;
    }

    return self;
}

- (void)createContainers
{
    [_sources enumerateObjectsUsingBlock:^(NSURL *source, NSUInteger idx, BOOL *stop) {
        [self p_createContainer:source];
    }];
}

- (void)p_createContainer:(NSURL *)sourceURL
{
    
}

- (void)p_findPlaybackPlugin:(NSURL *)sourceURL
{

}

@end
