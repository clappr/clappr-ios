//
//  CLPMediaControl.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/18/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPUIObject.h"

extern NSString *const CLPMediaControlEventPlaying;
extern NSString *const CLPMediaControlEventNotPlaying;

@class CLPContainer;
@class CLPScrubberView;

@interface CLPMediaControl : CLPUIObject

@property (nonatomic, strong, readwrite) CLPContainer *container;

@property (nonatomic, weak, readonly) UIButton *playPauseButton;

@property (nonatomic, weak, readonly) UIView *controlsOverlayView;
@property (nonatomic, weak, readonly) UIView *controlsWrapperView;

@property (nonatomic, weak, readonly) CLPScrubberView *scrubberView;
@property (nonatomic, weak, readonly) UILabel *durationLabel;
@property (nonatomic, weak, readonly) UILabel *currentTimeLabel;
@property (nonatomic, weak, readonly) UIButton *fullscreenButton;

@property (nonatomic, assign, getter=areControlsHidden) BOOL controlsHidden;

- (instancetype)initWithContainer:(CLPContainer *)container;

- (void)hide;
- (void)hideAnimated:(BOOL)animated;

- (void)show;
- (void)showAnimated:(BOOL)animated;

@end
