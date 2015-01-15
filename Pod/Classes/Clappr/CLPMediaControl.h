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

@interface CLPMediaControl : CLPUIObject

@property (nonatomic, strong, readwrite) CLPContainer *container;
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
@property (nonatomic, strong, readonly) UIButton *stopButton;
@property (nonatomic, strong, readonly) UISlider *volumeSlider;

- (instancetype)initWithContainer:(CLPContainer *)container;

- (void)show;
- (void)showAnimated:(BOOL)animated;

- (void)hide;
- (void)hideAnimated:(BOOL)animated;

@end
