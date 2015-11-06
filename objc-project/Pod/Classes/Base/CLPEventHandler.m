#import "CLPEventHandler.h"


@implementation CLPEventHandler
{
    EventCallback _callback;
}

- (instancetype)initWithCallback:(EventCallback)callback
{
    self = [super init];
    if (self) {
        _callback = callback;
    }
    return self;
}

- (void)handleEvent:(NSNotification *)notification;
{
    if (_callback)
        _callback(notification.userInfo);
}

@end
