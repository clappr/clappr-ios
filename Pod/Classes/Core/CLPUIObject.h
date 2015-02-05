#import "CLPBaseObject.h"

@interface CLPUIObject : CLPBaseObject

@property (nonatomic, readwrite) IBOutlet UIView *view;

- (instancetype)remove;

@end
