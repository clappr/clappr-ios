#import <Foundation/Foundation.h>
#import "CLPUIObject.h"

@class CLPMediaControl;


@interface CLPCore : CLPUIObject

@property (nonatomic, copy, readonly) NSArray *sources;
@property (nonatomic, copy, readonly) NSArray *containers;
@property (nonatomic, strong, readonly) CLPMediaControl *mediaControl;

- (instancetype)initWithSources:(NSArray *)sources;

- (void)loadSources:(NSArray *)sources;

- (void)addPlugin:(id)plugin;
- (BOOL)hasPlugin:(Class)pluginClass;

@end
