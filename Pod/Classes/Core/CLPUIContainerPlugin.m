#import "CLPUIContainerPlugin.h"
#import "CLPContainer.h"

@implementation CLPUIContainerPlugin

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;
        self.enabled = YES;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithContainer: instead"
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

