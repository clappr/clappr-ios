#import "CLPPlayer.h"

// Clappr
#import "CLPCore.h"
#import "UIView+NSLayoutConstraints.h"

static NSString *const kPlayerSampleMP4 = @"https://github.com/globocom/clappr-website/raw/gh-pages/highline.mp4";


@interface CLPPlayer ()
{
    CLPCore *core;
}
@end


@implementation CLPPlayer

- (instancetype)init
{
    return [self initWithOptions:nil];
}

- (instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        core = [[CLPCore alloc] initWithSources:@[kPlayerSampleMP4]];
    }
    return self;
}

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container
{
    core.view.backgroundColor = [UIColor blackColor];

    [container clappr_addSubviewMatchingFrameOfView:core.view];
}


#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
