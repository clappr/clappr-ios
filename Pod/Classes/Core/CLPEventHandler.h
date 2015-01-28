#import <Foundation/Foundation.h>

typedef void (^EventCallback)(NSDictionary *userInfo);


@interface CLPEventHandler : NSObject

- (instancetype)initWithCallback:(EventCallback)callback;
- (void)handleEvent:(NSNotification *)notification;

@end
