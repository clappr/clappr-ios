#import <UIKit/UIKit.h>

@class AVPlayer;
@class CLPAVPlayerView;

@interface Player : UIViewController

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) IBOutlet CLPAVPlayerView *playerView;

- (instancetype)initWithOptions:(NSDictionary *)options;
- (void)attachTo:(UIViewController *)controller atView:(UIView *)container;

@end
