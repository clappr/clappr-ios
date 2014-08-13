//
//  Player.m
//  Pods
//
//  Created by Thiago Pontes on 8/11/14.
//
//

#import "Player.h"
#import <AVFoundation/AVFoundation.h>

@interface Player ()
{
    AVPlayer* player;
}

@property (weak, nonatomic) IBOutlet UIView *controlsOverlay;
@property (weak, nonatomic) IBOutlet UIView *scrubber;
@property (weak, nonatomic) IBOutlet UIView *scrubberCenter;

@end

@implementation Player

+ (Player*) newPlayerWithOptions: (NSDictionary*) options
{
    return [[Player alloc] initWithNibName:@"Player" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupControlsOverlay];
    [self setupScrubber];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupControlsOverlay
{
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = _controlsOverlay.bounds;
    UIColor* startColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    UIColor* endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    gradient.colors = [NSArray arrayWithObjects:(id) [endColor CGColor], [startColor CGColor], nil];
    [_controlsOverlay.layer insertSublayer:gradient atIndex:0];
}

- (void) setupScrubber
{
    _scrubber.layer.cornerRadius = _scrubber.frame.size.width / 2;
    _scrubberCenter.layer.cornerRadius = _scrubberCenter.frame.size.width / 2;
}

- (void) attachTo:(UIViewController *)controller atView:(UIView *)container
{
    [controller addChildViewController:self];
    [container addSubview:self.view];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:@{@"view": self.view}]];

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.view}]];

    [container setNeedsLayout];
}

- (CMTime) duration
{
    return player.currentItem.duration;
}

@end
