#import "CLPSpinnerThreeBouncePlugin.h"
#import "CLPContainer.h"

@interface CLPSpinnerThreeBouncePlugin ()
{
    UILabel *loadingLabel;
}
@end

@implementation CLPSpinnerThreeBouncePlugin

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super initWithContainer:container];
    if (self) {
        loadingLabel = [UILabel new];
        loadingLabel.text = @"loading...";
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.hidden = YES;
        [container.view addSubview:loadingLabel];
    }
    return self;
}

- (void)bindEvents
{
    [self listenTo:self.container eventName:CLPContainerEventBuffering callback:^(NSDictionary *userInfo) {
        NSLog(@">>> CLPContainerEventBuffering");
    }];

    [self listenTo:self.container eventName:CLPContainerEventBufferFull callback:^(NSDictionary *userInfo) {
        NSLog(@">>> CLPContainerEventBufferFull");
    }];

    [self listenTo:self.container eventName:CLPContainerEventStop callback:^(NSDictionary *userInfo) {
        NSLog(@">>> CLPContainerEventStop");
    }];
}

@end
