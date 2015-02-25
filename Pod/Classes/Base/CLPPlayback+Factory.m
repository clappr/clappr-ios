#import "CLPPlayback+Factory.h"

#import "CLPLoader.h"

@implementation CLPPlayback (Factory)

+ (instancetype)playbackForURL:(NSURL *)url
{
    CLPLoader *loader = [CLPLoader sharedInstance];

    __block Class playbackClass;
    [loader.playbackPlugins enumerateObjectsUsingBlock:^(id pluginClass, NSUInteger idx, BOOL *stop) {

        if ([pluginClass canPlayURL:url]) {
            playbackClass = pluginClass;
            *stop = YES;
        }
    }];

    return [[playbackClass alloc] initWithURL:url];
}

@end
