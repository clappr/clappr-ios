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

- (instancetype)render
{
    return self;
}

- (instancetype)remove
{
    [_view removeFromSuperview];
    return self;
}

@end
