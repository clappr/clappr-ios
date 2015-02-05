#import "CLPBaseObject.h"

@interface CLPUIObject : CLPBaseObject

@property (nonatomic, strong, readwrite) IBOutlet UIView *view;

- (instancetype)remove;

@end
