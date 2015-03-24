//
//  FakePlugins.h
//  Clappr
//
//  Created by Gustavo Barbosa on 3/24/15.
//  Copyright (c) 2015 globo.com. All rights reserved.
//

#import <Clappr/Clappr.h>

#pragma mark - Core

@interface FakeUICorePlugin : CLPUICorePlugin
@end

#pragma mark - Container

@interface FakeUIContainerPlugin : CLPUIContainerPlugin
@end

#pragma mark - Playback

@interface FakePlaybackPlugin : CLPPlayback
@end

#pragma mark - Other

@interface OtherKindOfPlugin : NSObject
@end
