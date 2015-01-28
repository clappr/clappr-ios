#import <UIKit/UIKit.h>

@class CLPCore;

@interface CLPPlayer : UIViewController

@property (nonatomic, strong, readonly) CLPCore *core;

- (instancetype)initWithSourceURL:(NSURL *)sourceURL;
- (instancetype)initWithSourcesURLs:(NSArray *)sourcesURLs;

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container;

@end
