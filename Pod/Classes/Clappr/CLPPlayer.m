//
//  CLPPlayer.m
//  Clappr
//
//  Created by Gustavo Barbosa on 1/22/15.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

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
