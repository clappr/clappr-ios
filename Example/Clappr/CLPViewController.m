#import "CLPViewController.h"

#import <Clappr/Clappr.h>

static NSString *const kSourceURLString = @"https://github.com/globocom/clappr-website/raw/gh-pages/highline.mp4";

@interface CLPViewController ()
{
    CLPPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UITextField *mediaURLTextField;

@end


@implementation CLPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *sourceURL = [NSURL URLWithString:kSourceURLString];
    player = [[CLPPlayer alloc] initWithSourceURL:sourceURL];
    [player attachTo:self atView:_playerContainer];
}

- (IBAction)loadButtonDidTap
{
    NSLog(@">>> %@", _mediaURLTextField.text);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
