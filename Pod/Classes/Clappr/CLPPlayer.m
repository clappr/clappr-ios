//
//  CLPPlayer.m
//  Pods
//
//  Created by Gustavo Barbosa on 1/22/15.
//
//

#import "CLPPlayer.h"

// Clappr
#import "CLPCore.h"

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

    [container addSubview:core.view];

    core.view.translatesAutoresizingMaskIntoConstraints = NO;
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": core.view}]];

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": core.view}]];
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
