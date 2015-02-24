#import "CLPUIObject.h"

@class CLPContainer;

@interface CLPUIContainerPlugin : CLPUIObject

@property (nonatomic, strong, readonly) CLPContainer *container;
@property (nonatomic, assign, readwrite, getter=isEnabled) BOOL enabled;

- (instancetype)initWithContainer:(CLPContainer *)container;

@end
