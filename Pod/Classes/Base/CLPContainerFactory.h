#import "CLPBaseObject.h"

@class CLPLoader;


@interface CLPContainerFactory : CLPBaseObject

@property (nonatomic, strong, readonly) NSArray *sources;
@property (nonatomic, strong, readonly) CLPLoader *loader;

- (instancetype)initWithSources:(NSArray *)sources loader:(CLPLoader *)loader;

- (void)createContainers;

@end
