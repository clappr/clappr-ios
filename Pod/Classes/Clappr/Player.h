//
//  Player.h
//  Pods
//
//  Created by Thiago Pontes on 8/11/14.
//
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class PlayerView;

@interface Player : UIViewController

@property (nonatomic) AVPlayer* player;

@property (weak, nonatomic) IBOutlet PlayerView* playerView;

+ (Player*) newPlayerWithOptions: (NSDictionary*) options;

- (void) attachTo: (UIViewController*) controller atView: (UIView*) container;

@end
