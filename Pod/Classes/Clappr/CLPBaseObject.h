//
//  CLPBaseObject.h
//  Clappr
//
//  Created by Gustavo Barbosa on 12/4/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EventCallback)(NSDictionary *userInfo);

@class CLPCallback;

@interface CLPBaseObject : NSObject

- (void)on:(NSString *)eventName callback:(EventCallback)callback;
- (void)once:(NSString *)eventName callback:(EventCallback)callback;
- (void)off:(NSString *)eventName callback:(EventCallback)callback;
- (void)trigger:(NSString *)eventName;

@end
