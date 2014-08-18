//
//  CLPViewController.m
//  Clappr
//
//  Created by thiagopnts on 08/11/2014.
//  Copyright (c) 2014 thiagopnts. All rights reserved.
//

#import "CLPViewController.h"

@interface CLPViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerContainer;

@property (strong, nonatomic) Player* player;

@end

@implementation CLPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.player = [Player newPlayerWithOptions:nil];
    
    [self.player attachTo:self atView:self.playerContainer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
