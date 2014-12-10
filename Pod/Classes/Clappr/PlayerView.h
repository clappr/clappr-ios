//
//  PlayerView.h
//  Clappr
//
//  Created by Thiago Pontes on 8/14/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface PlayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void) setPlayer: (AVPlayer*) player;

@end
