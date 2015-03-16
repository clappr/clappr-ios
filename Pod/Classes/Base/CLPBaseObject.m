#import "CLPBaseObject.h"


@interface CLPBaseObject ()
{
    NSMutableDictionary *_eventHandlers;
}

@end


@implementation CLPBaseObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventHandlers = [@{} mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    [self stopListening];
}

- (void)on:(NSString *)eventName callback:(EventCallback)callback
{
    [self on:eventName contextObject:self callback:callback];
}

- (void)on:(NSString *)eventName contextObject:(CLPBaseObject *)contextObject callback:(EventCallback)callback
{
    if (!callback)
        return;

    CLPEventHandler *eventHandler = [[CLPEventHandler alloc] initWithCallback:callback];

    [[NSNotificationCenter defaultCenter] addObserver:eventHandler
                                             selector:@selector(handleEvent:)
                                                 name:eventName
                                               object:contextObject];

    id key = [self keyForEventName:eventName callback:callback contextObject:contextObject];
    _eventHandlers[key] = eventHandler;
}

- (id)keyForEventName:(NSString *)eventName
             callback:(EventCallback)callback
        contextObject:(CLPBaseObject *)contextObject
{
    return @{
        @"name": eventName,
        @"callback": callback,
        @"obj": contextObject
    };
}

- (void)once:(NSString *)eventName callback:(EventCallback)callback
{
    __weak typeof(self) weakSelf = self;
    __weak __block EventCallback blockSelf;

    EventCallback wrapperCallback = [^(NSDictionary *userInfo) {
        if (callback)
            callback(userInfo);

        [weakSelf off:eventName callback:blockSelf];
    } copy];

    blockSelf = wrapperCallback;

    [self on:eventName callback:wrapperCallback];
}

- (void)off:(NSString *)eventName callback:(EventCallback)callback
{
    [self off:eventName contextObject:self callback:callback];
}

- (void)off:(NSString *)eventName contextObject:(CLPBaseObject *)contextObject callback:(EventCallback)callback
{
    if (!callback)
        return;

    id key = [self keyForEventName:eventName callback:callback contextObject:contextObject];
    CLPEventHandler *eventHandler = _eventHandlers[key];

    [[NSNotificationCenter defaultCenter] removeObserver:eventHandler
                                                    name:eventName
                                                  object:contextObject];

    [_eventHandlers removeObjectForKey:key];
}

- (void)trigger:(NSString *)eventName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:@{}];
}

- (void)trigger:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:userInfo];
}

- (void)listenTo:(CLPBaseObject *)contextObject
       eventName:(NSString *)eventName
        callback:(EventCallback)callback
{
    [self on:eventName contextObject:contextObject callback:callback];
}

- (void)stopListening
{
    for (id key in _eventHandlers.allKeys) {
        CLPEventHandler *eventHandler = _eventHandlers[key];
        [[NSNotificationCenter defaultCenter] removeObserver:eventHandler];
    }

    [_eventHandlers removeAllObjects];
}

- (void)stopListening:(CLPBaseObject *)contextObject
            eventName:(NSString *)eventName
             callback:(EventCallback)callback
{
    [self off:eventName contextObject:contextObject callback:callback];
}

@end
