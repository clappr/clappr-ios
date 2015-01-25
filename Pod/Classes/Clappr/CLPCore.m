//
//  CLPCore.m
//  Clappr
//
//  Created by Gustavo Barbosa on 1/12/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import "CLPCore.h"

#import "CLPMediaControl.h"
#import "CLPContainer.h"
#import "CLPPlayback.h"
#import "UIView+NSLayoutConstraints.h"

static NSTimeInterval const kCoreMediaControlAnimationDuration = 0.3;

@interface CLPCore ()
{
    NSMutableArray *containers;
}

@property (nonatomic, assign) BOOL mediaControlHidden;

@end


@implementation CLPCore

- (instancetype)initWithSources:(NSArray *)sources
{
    self = [super init];
    if (self) {
        _sources = sources;
        [self createContainers];
        [self createMediaControl];
        [self addTapGestureToShowAndHideMediaControl];

        self.view.backgroundColor = [UIColor greenColor];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithSources: instead"
                                 userInfo:nil];
}

- (void)createContainers
{
    containers = [@[] mutableCopy];

    for (id source in _sources) {

        NSURL *sourceURL;
        if ([source isKindOfClass:[NSString class]])
            sourceURL = [NSURL URLWithString:source];
        else if ([source isKindOfClass:[NSURL class]])
            sourceURL = source;

        if (!sourceURL)
            continue;

        CLPPlayback *playback = [[CLPPlayback alloc] initWithURL:sourceURL];
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
    [self.mediaControl.view addGestureRecognizer:tapGesture];
}

- (void)toggleMediaControlVisibility
{
    if (_mediaControlHidden) {
        [self showMediaControl];
    } else {
        [self hideMediaControl];
    }
}

- (void)showMediaControl
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kCoreMediaControlAnimationDuration animations:^{
        for (UIView *subview in _mediaControl.view.subviews) {
            subview.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        if (finished)
            weakSelf.mediaControlHidden = NO;
    }];
}

- (void)hideMediaControl
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kCoreMediaControlAnimationDuration animations:^{
        for (UIView *subview in _mediaControl.view.subviews) {
            subview.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (finished)
            weakSelf.mediaControlHidden = YES;
    }];
}

#pragma mark - Accessors

- (NSArray *)containers
{
    return [containers copy];
}

@end
