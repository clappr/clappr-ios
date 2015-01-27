//
//  CLPUIObject.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/10/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPBaseObject.h"

@interface CLPUIObject : CLPBaseObject

@property (nonatomic, readwrite) IBOutlet UIView *view;

- (instancetype)render;
- (instancetype)remove;

@end
