#import <UIKit/UIKit.h>

@class CLPCore;


@interface CLPPlayer : UIViewController

@property (nonatomic, strong, readonly) CLPCore *core;
@property (nonatomic, strong, readwrite) NSURL *sourceURL;

- (instancetype)initWithSourceURL:(NSURL *)sourceURL;

- (void)attachTo:(UIViewController *)controller atView:(UIView *)container;

@end
