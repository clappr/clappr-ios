//
//  FullscreenViewController.m
//  Pods
//
//  Created by Thiago Pontes on 8/25/14.
//
//

#import "FullscreenViewController.h"

@interface FullscreenViewController ()

@end

@implementation FullscreenViewController

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
    self.view = [[UIView alloc]
                  initWithFrame: CGRectMake(0, 0,
                                    [[UIScreen mainScreen] applicationFrame].size.width,
                                    [[UIScreen mainScreen] applicationFrame].size.height + [UIApplication sharedApplication].statusBarFrame.size.height)];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
