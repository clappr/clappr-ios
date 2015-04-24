#import "CLPEventHandler.h"

@class CLPBaseObject;


@protocol CLPEventProtocol <NSObject>

- (void)on:(NSString *)eventName callback:(EventCallback)callback;

- (void)once:(NSString *)eventName callback:(EventCallback)callback;

- (void)off:(NSString *)eventName callback:(EventCallback)callback;

- (void)trigger:(NSString *)eventName;
- (void)trigger:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

- (void)listenTo:(id<CLPEventProtocol>)contextObject
       eventName:(NSString *)eventName
        callback:(EventCallback)callback;

- (void)stopListening;

- (void)stopListening:(id<CLPEventProtocol>)contextObject
            eventName:(NSString *)eventName
             callback:(EventCallback)callback;

@end


@interface CLPBaseObject : NSObject <CLPEventProtocol>

@end
