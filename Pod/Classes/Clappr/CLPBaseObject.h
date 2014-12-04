//
//  CLPBaseObject.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLPCallback;

@interface CLPBaseObject : NSObject

- (void)on:(NSString *)eventName callback:(CLPCallback *)callback;
- (void)off:(NSString *)eventName callback:(CLPCallback *)callback;
- (void)trigger:(NSString *)eventName;

@end
