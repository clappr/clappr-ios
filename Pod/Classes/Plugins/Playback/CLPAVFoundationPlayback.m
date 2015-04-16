#import "CLPAVFoundationPlayback.h"

#import <AVFoundation/AVFoundation.h>
#import "UIView+NSLayoutConstraints.h"

void *kStatusDidChangeKVO = &kStatusDidChangeKVO;
void *kTimeRangesKVO = &kTimeRangesKVO;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeKeyValueObservers];
}

- (void)removeKeyValueObservers
{
    @try {
        [_avPlayer removeObserver:self forKeyPath:@"currentItem.status"];

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

    [self addKeyValueObservers];

    [self addTimeElapsedCallbackHandler];
}

- (void)addKeyValueObservers
{
    [_avPlayer addObserver:self forKeyPath:@"currentItem.status" options:NSKeyValueObservingOptionNew context:kStatusDidChangeKVO];
    [_avPlayer addObserver:self forKeyPath:@"currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:kTimeRangesKVO];
}

- (void)addTimeElapsedCallbackHandler
{
    __weak typeof(self) weakSelf = self;
    [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, 600) queue:nil usingBlock:^(CMTime time) {
        if (weakSelf.isPlaying) {
            NSDictionary *userInfo = @{
                @"position": @(CMTimeGetSeconds(time)),
                @"duration": @(CMTimeGetSeconds(weakSelf.avPlayer.currentItem.asset.duration))
            };

            [weakSelf trigger:CLPPlaybackEventTimeUpdated userInfo:userInfo];
        }
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
    if (context == kStatusDidChangeKVO) {
        if (_avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            avPlayerLayer.frame = avPlayerLayer.superlayer.bounds;
            [self trigger:CLPPlaybackEventReady];
        } else if (_avPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            [self trigger:CLPPlaybackEventError userInfo:@{@"error": _avPlayer.currentItem.error}];
            [self removeKeyValueObservers];
        }
    } else if (context == kTimeRangesKVO) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges != (id)[NSNull null] && timeRanges.count) {
            CMTimeRange timerange = [timeRanges[0] CMTimeRangeValue];

            NSDictionary *userInfo = @{
                @"start_position": @(CMTimeGetSeconds(timerange.start)),
                @"end_position": @(CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration))),
                @"duration": @(CMTimeGetSeconds(_avPlayer.currentItem.asset.duration))
            };
            [self trigger:CLPPlaybackEventProgress userInfo:userInfo];
        }
    }
}

@end
