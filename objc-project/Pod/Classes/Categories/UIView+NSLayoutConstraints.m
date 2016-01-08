#import "UIView+NSLayoutConstraints.h"

@implementation UIView (NSLayoutConstraints)

- (void)clappr_addSubviewMatchingFrameOfView:(UIView *)view
{
    [self addSubview:view];

    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(view)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(view)]];
}

@end
