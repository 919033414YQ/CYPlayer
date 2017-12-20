//
//  CYVideoPlayer.h
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CYVideoPlayerState.h"
#import "CYVideoPlayerAssetCarrier.h"
#import "CYVideoPlayerMoreSettingSecondary.h"
#import "CYVideoPlayerSettings.h"
#import "CYPrompt.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  present View. support autoLayout.
 *
 *  播放器视图
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  error. support observe. default is nil.
 *
 *  播放报错, 如果需要, 可以使用观察者, 来观察他的改变.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, assign, readonly) CYVideoPlayerPlayState state;

@end


#pragma mark - 

@interface CYVideoPlayer (Setting)

- (void)playWithURL:(NSURL *)playURL;

// unit: sec.
- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

/*!
 *  Video URL
 *
 *  视频播放地址
 */
@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

/*!
 *  Create It By Video URL.
 **/
@property (nonatomic, strong, readwrite, nullable) CYVideoPlayerAssetCarrier *asset;

/*!
 *  clicked More button to display items.
 */
@property (nonatomic, strong, readwrite, nullable) NSArray<CYVideoPlayerMoreSetting *> *moreSettings;

- (void)settingPlayer:(void(^)(CYVideoPlayerSettings *settings))block;

- (void)resetSetting;

/*!
 *  rate
 *
 *  0.5..1.5
 **/
@property (nonatomic, assign, readwrite) float rate;

@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(CYVideoPlayer *player);

/*!
 *  loading show this.
 */
- (void)setPlaceholder:(UIImage *)placeholder;

/*!
 *  default is YES.
 *
 *  是否自动播放, 默认是 YES.
 */
@property (nonatomic, assign, readwrite, getter=isAutoplay) BOOL autoplay;

/*!
 *  default is YES.
 *
 *  是否自动生成预览视图, 默认是 YES.
 */
@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

/*!
 *  clicked back btn exe block.
 *
 *  点击返回按钮的回调
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(CYVideoPlayer *player);

/*!
 *  Whether screen rotation is disabled. default is NO.
 *
 *  是否禁用屏幕旋转, 默认是NO.
 */
@property (nonatomic, assign, readwrite) BOOL disableRotation;

@property (nonatomic, strong, readwrite) AVLayerVideoGravity videoGravity;

@end


#pragma mark -

@interface CYVideoPlayer (Control)

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)stopRotation;

- (void)enableRotation;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (UIImage *)screenshot;

/*!
 *  unit sec.
 */
- (NSTimeInterval)currentTime;

@end


#pragma mark -

@interface CYVideoPlayer (Prompt)

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

NS_ASSUME_NONNULL_END
