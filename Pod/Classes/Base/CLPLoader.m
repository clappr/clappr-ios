#import "CLPLoader.h"

#import "CLPCore.h"
#import "CLPContainer.h"
#import "CLPAVFoundationPlayback.h"

@interface CLPLoader ()
{
    NSArray *_playbackPlugins;
    NSArray *_containerPlugins;
    NSArray *_corePlugins;
}
@end

@implementation CLPLoader

+ (instancetype)sharedInstance
{
    static CLPLoader *sharedLoader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [self new];

    });

    return sharedLoader;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playbackPlugins = @[[CLPAVFoundationPlayback class]];
        _containerPlugins = @[];
        _corePlugins = @[];
    }
    return self;
}

- (BOOL)containsPlugin:(Class)pluginClass
{
    NSArray *plugins;
    if ([pluginClass isSubclassOfClass:[CLPPlayback class]])
        plugins = _playbackPlugins;
    else if ([pluginClass isSubclassOfClass:[CLPContainer class]])
        plugins = _containerPlugins;
    else if ([pluginClass isSubclassOfClass:[CLPCore class]])
        plugins = _corePlugins;

    __block NSInteger pluginIndex = NSNotFound;
    [plugins enumerateObjectsUsingBlock:^(Class objClass, NSUInteger idx, BOOL *stop) {
        if ([objClass isSubclassOfClass:pluginClass]) {
            pluginIndex = idx;
            *stop = YES;
        }
    }];

    return pluginIndex != NSNotFound;
}

@end
