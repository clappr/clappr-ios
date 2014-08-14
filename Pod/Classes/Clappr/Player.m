//
//  Player.m
//  Pods
//
//  Created by Thiago Pontes on 8/11/14.
//
//

#import "Player.h"

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@interface Player () <UIGestureRecognizerDelegate>
{
    BOOL mediaControlIsHidden;
}

@property (weak, nonatomic) IBOutlet UIView *controlsOverlay;
@property (weak, nonatomic) IBOutlet UIView *scrubber;
@property (weak, nonatomic) IBOutlet UIView *scrubberCenter;
@property (weak, nonatomic) IBOutlet UIView *seekBarContainer;
@property (weak, nonatomic) IBOutlet UIView *mediaControl;
@property (weak, nonatomic) IBOutlet UIButton *playPause;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *positionBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionBarConstraint;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *seekBarTap;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *seekBarDrag;

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

    _player = [AVPlayer playerWithURL: [NSURL URLWithString: @"http://www.html5rocks.com/en/tutorials/video/basics/devstories.mp4"]];
    [_playerView setPlayer: _player];

    [self setupControlsOverlay];

    [self setupScrubber];

    _player = [AVPlayer playerWithURL: [NSURL URLWithString: @"http://be.voddownload.globoi.com/03/e5/67/3064640_67b70de3abaeb35768f98b0dd01339c294b13da1/3064640-web360.mp4"]];
    [_playerView setPlayer: _player];
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
    _scrubber.layer.borderColor = [UIColor colorWithRed: 192 / 255.0f green: 192 / 255.0f blue: 192 / 255.0f alpha: 1].CGColor;
}

- (void) setupDuration
{
    [_durationLabel setText: [self getFormattedTime: _player.currentItem.asset.duration]];
}

- (NSString*) getFormattedTime: (CMTime) time
{
    //FIXME: there is a better way to do it, without `+(NSString*) stringWithFormat:`
    NSUInteger totalSeconds = CMTimeGetSeconds(time);
    NSUInteger minutes = floor(totalSeconds % 3600 / 60);
    NSUInteger seconds = floor(totalSeconds % 3600 % 60);
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long) minutes, (unsigned long) seconds];
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

- (void) scaleUpScrubber
{
    [UIView animateWithDuration: .3 animations: ^{
        _scrubber.transform = CGAffineTransformMakeScale(1.5, 1.5);
        _scrubber.layer.borderWidth = 1.0f / 1.5;
        _scrubberCenter.transform = CGAffineTransformMakeScale(0.5, 0.5);
    }];
}

- (void) undoScrubberTransform
{
    [UIView animateWithDuration: .3 animations: ^{
        _scrubber.layer.borderWidth = 0.0f;
        _scrubber.transform = CGAffineTransformIdentity;
        _scrubberCenter.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scaleUpScrubber];
    });
    return YES;
}

- (IBAction) toggleMediaControl:(UITapGestureRecognizer *)sender
{
    if (mediaControlIsHidden) {
        [self showMediaControl];
    } else {
        [self hideMediaControl];
    }
}

- (IBAction)togglePlayPause:(id)sender {
    if (_playPause.selected) {
        [_player pause];
    } else {
        [_player play];
    }
    _playPause.selected = !_playPause.selected;
}

- (IBAction) dragScrubber: (UIPanGestureRecognizer *) sender
{
    CGPoint translation = [sender locationInView: _seekBarContainer];
    [self updatePositionBarConstraints: translation.x];
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self undoScrubberTransform];
    }
}

- (IBAction) seekTo:(UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [sender locationInView: _seekBarContainer];
        [self updatePositionBarConstraints: position.x];
        [self undoScrubberTransform];
    }
}

- (CMTime) duration
{
    return _player.currentItem.duration;
}

@end
