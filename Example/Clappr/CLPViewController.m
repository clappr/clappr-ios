#import "CLPViewController.h"

#import <Clappr/Clappr.h>

//static NSString *const kSourceURLString = @"http://clappr.io/highline.mp4";
static NSString *const kSourceURLString = @"http://nba.cdn.turner.com/nba/big/channels/top_plays/2012/02/03/20120203_top10.nba_nba_ipad.mp4";

@interface CLPViewController () <UITextFieldDelegate>
{
    CLPPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UITextField *mediaURLTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@end


@implementation CLPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mediaURLTextField.text = kSourceURLString;

    _mediaURLTextField.accessibilityLabel = @"source url";
    _loadButton.accessibilityLabel = @"load button";

    NSURL *sourceURL = [NSURL URLWithString:kSourceURLString];
    player = [[CLPPlayer alloc] initWithSourceURL:sourceURL];
    [player attachTo:self atView:_playerContainer];
}

- (IBAction)loadButtonDidTap
{
    NSURL *url = [NSURL URLWithString:_mediaURLTextField.text];

    if (url)
        player.sourceURL = url;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return NO;
}

#pragma mark - UIStatusBarStyle

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
