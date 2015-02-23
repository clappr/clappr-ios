#import "CLPUICorePlugin.h"

@implementation CLPUICorePlugin

- (instancetype)initWithCore:(CLPCore *)core
{
    self = [super init];
    if (self) {
        _core = core;
        self.enabled = YES;
        [_core.view addSubview:self.view];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithCore: instead"
                                 userInfo:nil];
}

- (void)setEnabled:(BOOL)enabled
{
    if (!enabled) {
        [self stopListening];
        self.view.hidden = YES;
        _enabled = NO;
    } else {
        if (![self isEnabled]) {
            [self bindEvents];
            self.view.hidden = NO;
            _enabled = YES;
        }
    }
}

- (void)bindEvents
{
    // Empty implementation. Leave to subclasses.
}

@end
