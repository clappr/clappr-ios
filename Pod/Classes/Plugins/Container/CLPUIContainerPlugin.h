#import "CLPUIPlugin.h"

@class CLPContainer;

@interface CLPUIContainerPlugin : CLPUIPlugin

@property (nonatomic, strong, readonly) CLPContainer *container;

- (instancetype)initWithContainer:(CLPContainer *)container;

@end
