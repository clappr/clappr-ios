#import "CLPAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>


@interface CLPAVPlayerView ()

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@end


@implementation CLPAVPlayerView

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
