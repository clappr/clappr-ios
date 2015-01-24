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

@property (nonatomic, weak, readonly) UIButton *playPauseButton;
@property (nonatomic, weak, readonly) UILabel *durationLabel;
@property (nonatomic, weak, readonly) UILabel *currentTimeLabel;
@property (nonatomic, weak, readonly) UIButton *fullscreenButton;

- (instancetype)initWithContainer:(CLPContainer *)container;

- (void)show;
- (void)showAnimated:(BOOL)animated;

- (void)hide;
- (void)hideAnimated:(BOOL)animated;

@end
