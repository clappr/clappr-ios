#import "CLPBaseObject.h"

@class CLPPlayer;
@class CLPLoader;
@class CLPCore;

@interface CLPCoreFactory : CLPBaseObject

@property (nonatomic, strong, readonly) CLPPlayer *player;

- (instancetype)initWithPlayer:(CLPPlayer *)player;

- (CLPCore *)create;

@end
