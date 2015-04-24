#import "CLPUIObject.h"

@interface CLPUIObject()
{
    CLPBaseObject *_baseObject;
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation CLPUIObject
#pragma clang diagnostic pop

- (instancetype)init
{
    self = [super init];
    if (self) {
        _baseObject = [CLPBaseObject new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _baseObject = [CLPBaseObject new];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _baseObject = [CLPBaseObject new];
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_baseObject respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_baseObject];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
