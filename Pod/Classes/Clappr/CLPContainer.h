//
//  CLPContainer.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPUIObject.h"

@class CLPPlayback;

@interface CLPContainer : CLPUIObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;
@property (nonatomic, assign, readonly) NSDictionary *settings;
@property (nonatomic, assign, readonly, getter=isDVRInUse) BOOL dvrInUse;
@property (nonatomic, assign, readonly, getter=isMediaControlDisabled) BOOL mediaControlDisabled;

@property (nonatomic, strong, readwrite) CLPPlayback *playback;

- (instancetype)initWithPlayback:(CLPPlayback *)playback;

@end
