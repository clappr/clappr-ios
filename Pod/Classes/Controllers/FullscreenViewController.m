#import "FullscreenViewController.h"

@implementation FullscreenViewController

- (void)viewDidLoad
{
    self.view = [[UIView alloc]
                  initWithFrame: CGRectMake(0, 0,
                                    [[UIScreen mainScreen] applicationFrame].size.width,
                                    [[UIScreen mainScreen] applicationFrame].size.height + [UIApplication sharedApplication].statusBarFrame.size.height)];

    [super viewDidLoad];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end
