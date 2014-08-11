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

@property (weak, nonatomic) IBOutlet UIView *mediaControl;

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
    [self setupMediaControlGradient];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupMediaControlGradient
{
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = _mediaControl.bounds;
    UIColor* startColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    UIColor* endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    gradient.colors = [NSArray arrayWithObjects:(id) [endColor CGColor], [startColor CGColor], nil];
    [_mediaControl.layer insertSublayer:gradient atIndex:0];
}

- (void) attachTo:(UIViewController *)controller atView:(UIView *)container
{
    [controller addChildViewController:self];
    [container addSubview:self.view];
    self.view.frame = container.bounds;
}

- (CMTime) duration
{
    return player.currentItem.duration;
}

@end
