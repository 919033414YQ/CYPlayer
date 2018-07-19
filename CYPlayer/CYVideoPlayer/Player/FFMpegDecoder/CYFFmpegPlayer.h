//
//  CYFFmpegPlayer.h
//  CYPlayer
//
//  Created by 黄威 on 2018/7/19.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^LockScreen)(BOOL isLock);

typedef NS_ENUM(NSUInteger, CYFFmpegPlayerPlayState) {
    CYFFmpegPlayerPlayState_Unknown = 0,
    CYFFmpegPlayerPlayState_Prepare,
    CYFFmpegPlayerPlayState_Playing,
    CYFFmpegPlayerPlayState_Buffing,
    CYFFmpegPlayerPlayState_Pause,
    CYFFmpegPlayerPlayState_PlayEnd,
    CYFFmpegPlayerPlayState_PlayFailed,
};

@class CYMovieDecoder;

extern NSString * const CYMovieParameterMinBufferedDuration;    // Float
extern NSString * const CYMovieParameterMaxBufferedDuration;    // Float
extern NSString * const CYMovieParameterDisableDeinterlacing;   // BOOL

@interface CYFFmpegPlayer : NSObject

+ (id) movieViewWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;





/*!
 *  present View. support autoLayout.
 *
 *  播放器视图
 */
@property (nonatomic, strong) UIView *view;


@property (readonly) BOOL playing;

@property (nonatomic, assign, readonly) CYFFmpegPlayerPlayState state;

- (void) play;
- (void) pause;
- (void)viewDidAppear;
- (void)viewWillDisappear;

@end

# pragma mark -

@interface CYFFmpegPlayer (State)


@property (nonatomic, assign, readwrite, getter=isHiddenControl) BOOL hideControl;

@property (nonatomic, assign, readwrite, getter=isLockedScrren) BOOL lockScreen;

- (void)_playState;

- (void)_cancelDelayHiddenControl;

- (void)_delayHiddenControl;

@end

# pragma mark -

@interface CYFFmpegPlayer (Setting)

/*!
 *  Whether screen rotation is disabled. default is NO.
 *
 *  是否禁用屏幕旋转, 默认是NO.
 */
@property (nonatomic, assign, readwrite) BOOL disableRotation;

@property (nonatomic, assign, readwrite) float rate; /// 0.5 .. 1.5

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(CYFFmpegPlayer *player, BOOL isFullScreen);

@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(CYFFmpegPlayer *player, BOOL displayed);

/*!
 *  Call when the rate changes.
 *
 *  调速时调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(CYFFmpegPlayer *player);

@end


# pragma mark -

@interface CYFFmpegPlayer (Control)


@property (nonatomic, copy) LockScreen lockscreen;


@end

