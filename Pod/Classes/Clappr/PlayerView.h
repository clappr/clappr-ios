//
//  PlayerView.h
//  Pods
//
//  Created by Thiago Pontes on 8/14/14.
//
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface PlayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void) setPlayer: (AVPlayer*) player;

@end
