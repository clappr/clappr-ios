#import "CLPPlayer.h"

// Clappr
#import "CLPCore.h"
#import "CLPCoreFactory.h"
#import "CLPContainer.h"
#import "CLPLoader.h"
#import "UIView+NSLayoutConstraints.h"


@implementation CLPPlayer

- (instancetype)init
{
    return [self initWithSourcesURLs:@[]];
}

- (instancetype)initWithSourceURL:(NSURL *)sourceURL
{
    return [self initWithSourcesURLs:@[sourceURL]];
}

- (instancetype)initWithSourcesURLs:(NSArray *)sourcesURLs
{
    self = [super init];
    if (self) {
        CLPCoreFactory *factory = [[CLPCoreFactory alloc] initWithPlayer:self];
        _core = [factory create];
        if (sourcesURLs) {
            [_core loadSources:sourcesURLs];
        }
    }
    return self;
}

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container
{
    _core.view.backgroundColor = [UIColor blackColor];

    [container clappr_addSubviewMatchingFrameOfView:_core.view];
}

- (void)setSourceURL:(NSURL *)sourceURL
{
    _sourceURL = sourceURL;
    [_core loadSources:@[sourceURL]];
}

@end
