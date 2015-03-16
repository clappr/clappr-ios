#import "CLPAVFoundationPlayback.h"

#import <AVFoundation/AVFoundation.h>
#import "UIView+NSLayoutConstraints.h"


@interface CLPAVFoundationPlayback ()
{
    AVPlayerLayer *avPlayerLayer;
}

@property (nonatomic, strong) AVPlayer *avPlayer;

@end


@implementation CLPAVFoundationPlayback

#pragma mark - Dtor

- (void)dealloc
{
    @try {
        [_avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *__unused exception) {}
}

#pragma mark - Ctors

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super initWithURL:url];
    if (self && url) {
        [self setupPlayer];
        [self bindEventListeners];
    }

    return self;
}

- (void)setupPlayer
{
    _avPlayer = [AVPlayer playerWithURL:self.url];

    _playerView = [CLPAVPlayerView new];
    _playerView.player = _avPlayer;
    [self.view clappr_addSubviewMatchingFrameOfView:_playerView];

    [_avPlayer.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self addTimeElapsedCallbackHandler];
}

- (void)addTimeElapsedCallbackHandler
{
    __weak typeof(self) weakSelf = self;
    [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:nil usingBlock:^(CMTime time) {

        NSDictionary *userInfo = @{
                                   @"position": @(CMTimeGetSeconds(time)),
                                   @"duration": @(CMTimeGetSeconds(weakSelf.avPlayer.currentItem.asset.duration))
                                   };

        [weakSelf trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];
    }];
}

- (void)bindEventListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_avPlayer.currentItem];
}

#pragma mark - Controls

- (void)play
{
    [_avPlayer play];
}

- (void)pause
{
    [_avPlayer pause];
}

- (NSUInteger)duration
{
    BOOL playerIsReady = _avPlayer.status == AVPlayerStatusReadyToPlay;
    if (!playerIsReady)
        return 0;

    return CMTimeGetSeconds(_avPlayer.currentItem.asset.duration);
}

- (BOOL)isPlaying
{
    return _avPlayer.rate > 0.0f;
}

- (void)destroy
{
    [super destroy];
}

+ (BOOL)canPlayURL:(NSURL *)url
{
    return YES; //TODO
}

#pragma mark - Callback handlers

- (void)playbackDidEnd
{
    [_avPlayer.currentItem seekToTime:kCMTimeZero];
    [self trigger:CLPPlaybackEventEnded];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == _avPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        if (_avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            avPlayerLayer.frame = avPlayerLayer.superlayer.bounds;
            [self trigger:CLPPlaybackEventReady];
        } else if (_avPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            [self trigger:CLPPlaybackEventError userInfo:@{@"error": _avPlayer.currentItem.error}];
            [_avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        }
    }
}

@end
