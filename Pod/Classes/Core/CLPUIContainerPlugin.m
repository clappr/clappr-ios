#import "CLPUIContainerPlugin.h"

@implementation CLPUIContainerPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled == enabled) {
        return;
    }

    _enabled = enabled;

    if (!_enabled) {
        [self stopListening];
    }

    self.view.hidden = !_enabled;
}

@end

