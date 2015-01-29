#import "CLPPlayer.h"

// Clappr
#import "CLPCore.h"
#import "CLPContainer.h"
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
        _core = [[CLPCore alloc] initWithSources:sourcesURLs ?: @[]];
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
