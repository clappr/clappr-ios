//
//  UIView+NSLayoutConstraints.m
//  Clappr
//
//  Created by Gustavo Barbosa on 1/22/15.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "UIView+NSLayoutConstraints.h"

@implementation UIView (NSLayoutConstraints)

- (void)clappr_addSubviewMatchingFrame:(UIView *)view
{
    [self addSubview:view];

    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(view)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(view)]];
}

@end
