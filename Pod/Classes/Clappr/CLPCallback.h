//
//  CLPCallback.h
//  Pods
//
//  Created by Gustavo Barbosa on 12/4/14.
//
//

#import <Foundation/Foundation.h>

@interface CLPCallback : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, assign, readonly) SEL selector;

- (instancetype)initWithTarget:(id)target selector:(SEL)selector;
+ (instancetype)callbackWithTarget:(id)target selector:(SEL)selector;

- (BOOL)isEqualToCallback:(CLPCallback *)callback;
- (void)execute;

@end
