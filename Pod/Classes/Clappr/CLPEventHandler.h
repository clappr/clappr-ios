//
//  CLPEventHandler.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/9/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EventCallback)(NSDictionary *userInfo);


@interface CLPEventHandler : NSObject

- (instancetype)initWithCallback:(EventCallback)callback;
- (void)handleEvent;

@end
