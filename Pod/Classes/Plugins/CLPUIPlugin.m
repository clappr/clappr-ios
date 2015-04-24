#import "CLPUIPlugin.h"


@implementation CLPUIPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enabled = YES;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if (!enabled) {
        [self stopListening];
        self.hidden = YES;
        _enabled = NO;
    } else {
        if (![self isEnabled]) {
            [self bindEvents];
            self.hidden = NO;
            _enabled = YES;
        }
    }
}

- (void)bindEvents
{
    // Empty implementation. Leave to subclasses.
}

@end
