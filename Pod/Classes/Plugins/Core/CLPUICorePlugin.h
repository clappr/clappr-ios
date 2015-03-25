#import "CLPUIPlugin.h"

@class CLPCore;


@interface CLPUICorePlugin : CLPUIPlugin

@property (nonatomic, readonly, weak) CLPCore *core;

- (instancetype)initWithCore:(CLPCore *)core;

@end
