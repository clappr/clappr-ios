#import "CLPUIPlugin.h"

@class CLPCore;


@interface CLPUICorePlugin : CLPUIPlugin

@property (nonatomic, readonly, strong) CLPCore *core;

- (instancetype)initWithCore:(CLPCore *)core;

@end
