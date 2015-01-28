#import <UIKit/UIKit.h>

@class AVPlayer;
@class PlayerView;

@interface Player : UIViewController

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) IBOutlet PlayerView *playerView;

- (instancetype)initWithOptions:(NSDictionary *)options;
- (void)attachTo:(UIViewController *)controller atView:(UIView *)container;

@end
