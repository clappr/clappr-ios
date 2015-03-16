#import "CLPUIObject.h"


@implementation CLPUIObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _view = [UIView new];
    }
    return self;
}

- (instancetype)remove
{
    [self stopListening];
    [_view removeFromSuperview];
    return self;
}

@end
