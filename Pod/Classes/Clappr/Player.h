//
//  Player.h
//  Pods
//
//  Created by Thiago Pontes on 8/11/14.
//
//

#import <UIKit/UIKit.h>

@interface Player : UIViewController

+ (Player*) newPlayerWithOptions: (NSDictionary*) options;

- (void) attachTo: (UIViewController*) controller atView: (UIView*) container;

@end
