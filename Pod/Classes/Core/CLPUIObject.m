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
    [_view removeFromSuperview];
    [self stopListening];
    return self;
}

@end
