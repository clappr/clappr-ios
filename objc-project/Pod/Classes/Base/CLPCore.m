#import "CLPCore.h"

#import "CLPLoader.h"
#import "CLPMediaControl.h"
#import "CLPContainer.h"
#import "CLPPlayback.h"
#import "CLPPlayback+Factory.h"
#import "CLPContainerFactory.h"
#import "CLPUICorePlugin.h"
#import "UIView+NSLayoutConstraints.h"


@interface CLPCore ()
{
    NSMutableArray *containers;
    NSMutableSet *_plugins;
}

@end


@implementation CLPCore

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithSources: instead"
                                 userInfo:nil];
}

- (instancetype)initWithSources:(NSArray *)sources
{
    self = [super init];
    if (self) {
        _plugins = [@[] mutableCopy];
        [self loadSources:sources];
    }
    return self;
}

- (void)loadSources:(NSArray *)sources
{
    _sources = sources;

    [self recreateContainers];
    [self createMediaControl];
    [self addTapGestureToShowAndHideMediaControl];
}

- (void)recreateContainers
{
    for (CLPContainer *container in containers) {
        [container destroy];
    }

    [self createContainers];
}

- (void)createContainers
{
    containers = [@[] mutableCopy];

    CLPContainerFactory *containerFactory = [[CLPContainerFactory alloc] initWithSources:_sources loader:[CLPLoader new]];

    NSArray *createdContainers = [containerFactory createContainers];
    for (CLPContainer *container in createdContainers) {
        [self clappr_addSubviewMatchingFrameOfView:container];
        [containers addObject:container];
    }
}

- (void)createMediaControl
{
    CLPContainer *topContainer = [containers firstObject];
    if (topContainer) {
        _mediaControl = [[CLPMediaControl alloc] initWithContainer:topContainer];
    }
}

- (void)addTapGestureToShowAndHideMediaControl
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(toggleMediaControlVisibility)];
    [_mediaControl addGestureRecognizer:tapGesture];
}

- (void)toggleMediaControlVisibility
{
    if ([_mediaControl areControlsHidden]) {
        [_mediaControl showAnimated:YES];
    } else {
        [_mediaControl hideAnimated:YES];
    }
}

#pragma mark - Plugins

- (void)addPlugin:(id)plugin
{
    if ([[plugin class] isSubclassOfClass:[CLPUICorePlugin class]]) {
        [_plugins addObject:plugin];
    }
}

- (BOOL)hasPlugin:(Class)pluginClass
{
    for (id plugin in _plugins) {
        if ([[plugin class] isSubclassOfClass:pluginClass]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Accessors

- (NSArray *)containers
{
    return [containers copy];
}

- (NSSet *)plugins
{
    return [_plugins copy];
}

@end
