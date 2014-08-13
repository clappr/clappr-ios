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
    BOOL mediaControlIsHidden;
}

@property (weak, nonatomic) IBOutlet UIView *controlsOverlay;
@property (weak, nonatomic) IBOutlet UIView *scrubber;
@property (weak, nonatomic) IBOutlet UIView *scrubberCenter;
@property (weak, nonatomic) IBOutlet UIView *seekBarContainer;
@property (weak, nonatomic) IBOutlet UIView *mediaControl;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *positionBar;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *positionBarConstraint;

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
        mediaControlIsHidden = false;
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

- (void) showMediaControl
{
    [UIView animateWithDuration: .3 animations: ^{
        _mediaControl.alpha = 1.0;
    }];
    mediaControlIsHidden = false;
}

- (void) hideMediaControl
{
    [UIView animateWithDuration: .3 animations: ^{
        _mediaControl.alpha = .0;
    }];
    mediaControlIsHidden = true;
}

- (void) updatePositionBarConstraints: (CGFloat) width
{
    _positionBarConstraint.constant = width;
    [_seekBarContainer setNeedsLayout];
}

- (IBAction) toggleMediaControl:(UITapGestureRecognizer *)sender
{
    NSLog(@"%d", mediaControlIsHidden);
    if (mediaControlIsHidden) {
        [self showMediaControl];
    } else {
        [self hideMediaControl];
    }
}

- (IBAction) seekTo:(UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [sender locationInView: _seekBarContainer];
        NSLog(@"translating to: %@", NSStringFromCGPoint(position));
        [self updatePositionBarConstraints: position.x];
    }
}

- (CMTime) duration
{
    return player.currentItem.duration;
}

@end
