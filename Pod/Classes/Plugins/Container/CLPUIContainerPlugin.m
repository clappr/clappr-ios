#import "CLPUIContainerPlugin.h"
#import "CLPContainer.h"

@implementation CLPUIContainerPlugin

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Use initWithContainer: instead"
                                 userInfo:nil];
}

@end

