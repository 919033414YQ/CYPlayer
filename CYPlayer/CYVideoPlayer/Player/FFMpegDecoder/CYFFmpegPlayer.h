//
//  CYFFmpegPlayer.h
//  CYPlayer
//
//  Created by 黄威 on 2018/7/19.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class
CYMovieDecoder,
CYVideoPlayerSettings,
CYPrompt,
CYVideoFrame;

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

typedef void (^CYPlayerImageGeneratorCompletionHandler)(NSMutableArray<CYVideoFrame *> * frames);



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
- (void)generatedPreviewImagesWithCount:(NSInteger)imagesCount completionHandler:(CYPlayerImageGeneratorCompletionHandler)handler;


@end

# pragma mark -

@interface CYFFmpegPlayer (State)


@property (nonatomic, assign, readwrite, getter=isHiddenControl) BOOL hideControl;

@property (nonatomic, assign, readwrite, getter=isLockedScrren) BOOL lockScreen;


- (void)_cancelDelayHiddenControl;

- (void)_delayHiddenControl;

- (void)_prepareState;

- (void)_playState;

- (void)_pauseState;

- (void)_playEndState;

- (void)_playFailedState;

- (void)_unknownState;

@end

# pragma mark -

@interface CYFFmpegPlayer (Setting)

/*!
 *  clicked back btn exe block.
 *
 *  点击返回按钮的回调.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(CYFFmpegPlayer *player);

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
 *  配置播放器, 注意: 这个`block`在子线程运行.
 **/
- (void)settingPlayer:(void(^)(CYVideoPlayerSettings *settings))block;
- (void)resetSetting;// 重置配置


/*!
 *  Call when the rate changes.
 *
 *  调速时调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(CYFFmpegPlayer *player);

/*!
 *  default is YES.
 *
 *  是否自动播放, 默认是 YES.
 */
@property (nonatomic, assign, readwrite, getter=isAutoplay) BOOL autoplay;

@end


# pragma mark -

@interface CYFFmpegPlayer (Control)

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

@property (nonatomic, copy) LockScreen lockscreen;


@end

#pragma mark -

@interface CYFFmpegPlayer (Prompt)

@property (nonatomic, strong, readonly) CYPrompt *prompt;

/*!
 *  duration default is 1.0
 */
- (void)showTitle:(NSString *)title;

/*!
 *  duration if value set -1, promptView will always show.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)hiddenTitle;

@end
