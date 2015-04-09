#import "CLPPlayback+Factory.h"

#import "CLPLoader.h"


@implementation CLPPlayback (Factory)

+ (instancetype)playbackForURL:(NSURL *)url
{
    __block Class playbackClass;
    [[CLPLoader sharedLoader].playbackPlugins enumerateObjectsUsingBlock:^(id pluginClass, NSUInteger idx, BOOL *stop) {

        if ([pluginClass canPlayURL:url]) {
            playbackClass = pluginClass;
            *stop = YES;
        }
    }];

    return [[playbackClass alloc] initWithURL:url];
}

@end
