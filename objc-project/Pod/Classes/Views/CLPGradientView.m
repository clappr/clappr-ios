#import "CLPGradientView.h"


@interface CLPGradientView ()
{
    CAGradientLayer *gradientLayer;
}
@end


@implementation CLPGradientView

- (void)awakeFromNib
{
    [super awakeFromNib];

    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[
        (id)[[UIColor clearColor] CGColor],
        (id)[[UIColor blackColor] CGColor]
    ];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)layoutSubviews
{
    gradientLayer.frame = self.bounds;
}

@end
