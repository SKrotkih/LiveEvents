#import <UIKit/UIKit.h>
@import YouTubeiOSPlayerHelper;

@interface VideoPlayer: NSObject <YTPlayerViewDelegate>

@property(nonatomic, strong) YTPlayerView *playerView;

- (instancetype) initWithVideoId: (NSString *)videoId;

- (void) playVideo;
- (void) start;
- (void) stop;
- (void) pause;
- (void) reverse;
- (void) forward;
- (void) seekToTime: (float) time;

@end
