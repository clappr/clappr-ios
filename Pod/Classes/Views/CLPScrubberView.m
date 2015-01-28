#import "CLPScrubberView.h"

@interface CLPScrubberView ()
{
    __weak IBOutlet UIView *outerCircle;
    __weak IBOutlet UIView *innerCircle;
}
@end

@implementation CLPScrubberView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupScrubber];
}

- (void)setupScrubber
{
    outerCircle.layer.cornerRadius = CGRectGetWidth(outerCircle.frame) / 2;
    innerCircle.layer.cornerRadius = CGRectGetWidth(innerCircle.frame) / 2;
    outerCircle.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1.0].CGColor;
}

@end
