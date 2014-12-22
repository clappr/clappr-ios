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
@property (nonatomic, assign, readwrite) float volume;

- (instancetype)initWithContainer:(CLPContainer *)container;

- (void)play;

@end
