//
//  Player.h
//  Clappr
//
//  Created by Thiago Pontes on 8/11/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class PlayerView;

@interface Player : UIViewController

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, weak) IBOutlet PlayerView *playerView;

+ (Player *)newPlayerWithOptions:(NSDictionary *)options;

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container;

@end
