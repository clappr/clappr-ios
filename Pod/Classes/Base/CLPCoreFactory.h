#import "CLPBaseObject.h"

@class CLPPlayer;
@class CLPLoader;
@class CLPCore;

@interface CLPCoreFactory : CLPBaseObject

@property (nonatomic, strong, readonly) CLPPlayer *player;
@property (nonatomic, strong, readonly) CLPLoader *loader;

- (instancetype)initWithPlayer:(CLPPlayer *)player loader:(CLPLoader *)loader;

- (CLPCore *)create;

@end
