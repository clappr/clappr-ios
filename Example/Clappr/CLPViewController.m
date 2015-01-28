#import "CLPViewController.h"

#import <Clappr/Clappr.h>


@interface CLPViewController ()
{
    CLPPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIView *playerContainer;

@end


@implementation CLPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    player = [CLPPlayer new];
    [player attachTo:self atView:_playerContainer];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
