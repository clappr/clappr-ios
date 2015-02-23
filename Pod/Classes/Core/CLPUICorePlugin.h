#import "CLPUIObject.h"
#import "CLPCore.h"

@interface CLPUICorePlugin : CLPUIObject

@property (nonatomic, readonly, strong) CLPCore *core;
@property (nonatomic, readwrite, assign, getter=isEnabled) BOOL enabled;

- (instancetype)initWithCore:(CLPCore *)core;

@end
