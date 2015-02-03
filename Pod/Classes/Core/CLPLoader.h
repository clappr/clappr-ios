#import "CLPBaseObject.h"

@interface CLPLoader : CLPBaseObject

@property (nonatomic, strong, readonly) NSArray *playbackPlugins;
@property (nonatomic, strong, readonly) NSArray *containerPlugins;
@property (nonatomic, strong, readonly) NSArray *corePlugins;

+ (instancetype)sharedInstance;

- (BOOL)containsPlugin:(Class)pluginClass;

@end
