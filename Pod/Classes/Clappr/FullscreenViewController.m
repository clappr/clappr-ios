//
//  FullscreenViewController.m
//  Clappr
//
//  Created by Thiago Pontes on 8/25/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

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
