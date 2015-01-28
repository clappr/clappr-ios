#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerView ()

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@end


@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player
{
    self.playerLayer.player = player;
}

#pragma mark - Accessors

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end
