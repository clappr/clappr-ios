#import "CLPContainerFactory.h"
#import "CLPContainer.h"
#import "CLPLoader.h"
#import "CLPPlayback.h"


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

- (NSArray *)createContainers
{
    NSMutableArray *containers = [@[] mutableCopy];
    for (NSURL *source in _sources) {
        [containers addObject:[self p_createContainer:source]];
    }

    return [containers copy];
}

- (CLPContainer *)p_createContainer:(NSURL *)sourceURL
{
    Class playbackPlugin = [self p_findPlaybackPlugin:sourceURL];
    CLPPlayback *playback = [[playbackPlugin alloc] initWithURL:sourceURL];
    CLPContainer *container = [[CLPContainer alloc] initWithPlayback:playback];
    [self p_addContainerPlugins:container];

    return container;
}

- (Class)p_findPlaybackPlugin:(NSURL *)sourceURL
{
    __block Class klass;

    for (Class pluginClass in _loader.playbackPlugins) {
        if ([pluginClass isSubclassOfClass:[CLPPlayback class]] &&
            [pluginClass canPlayURL:sourceURL]) {
            klass = pluginClass;
        }
    }

    return klass;
}

- (void)p_addContainerPlugins:(CLPContainer *)container
{
    for (Class pluginClass in _loader.containerPlugins) {
        id containerPlugin = [pluginClass new];
        [container addPlugin:containerPlugin];
    }
}

@end
