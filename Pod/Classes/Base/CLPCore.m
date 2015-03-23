#import "CLPCore.h"

#import "CLPMediaControl.h"
#import "CLPContainer.h"
#import "CLPPlayback.h"
#import "CLPPlayback+Factory.h"
#import "UIView+NSLayoutConstraints.h"


@interface CLPCore ()
{
    NSMutableArray *containers;
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

    for (id source in _sources) {

        NSURL *sourceURL;
        if ([source isKindOfClass:[NSString class]]) {
            sourceURL = [NSURL URLWithString:source];
        } else if ([source isKindOfClass:[NSURL class]]) {
            sourceURL = source;
        }

        if (!sourceURL)
            continue;

        CLPPlayback *playback = [CLPPlayback playbackForURL:sourceURL];
        CLPContainer *container = [[CLPContainer alloc] initWithPlayback:playback];

        [self.view clappr_addSubviewMatchingFrameOfView:container.view];

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
    [_mediaControl.view addGestureRecognizer:tapGesture];
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
    
}

- (BOOL)hasPlugin:(Class)pluginClass
{
    return NO;
}

#pragma mark - Accessors

- (NSArray *)containers
{
    return [containers copy];
}

@end
