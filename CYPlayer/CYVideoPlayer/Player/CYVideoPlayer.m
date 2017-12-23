//
//  CYVideoPlayer.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYVideoPlayer.h"
#import "CYVideoPlayerAssetCarrier.h"
#import <Masonry/Masonry.h>
#import "CYVideoPlayerPresentView.h"
#import "CYVideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/message.h>
#import "CYVideoPlayerResources.h"
#import <MediaPlayer/MPVolumeView.h>
#import "CYVideoPlayerMoreSettingsView.h"
#import "CYVideoPlayerMoreSettingSecondaryView.h"
#import "CYOrentationObserver.h"
#import "CYVideoPlayerRegistrar.h"
#import "CYVolBrigControl.h"
#import "CYTimerControl.h"
#import "CYVideoPlayerView.h"
#import "JDradualLoadingView.h"
#import "CYPlayerGestureControl.h"

#define MoreSettingWidth (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 0.382)

inline static void _cyErrorLog(id msg) {
    NSLog(@"__error__: %@", msg);
}

inline static void _cyHiddenViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 0.001;
    }];
}

inline static void _cyShowViews(NSArray<UIView *> *views) {
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 1;
    }];
}

inline static void _cyAnima(void(^block)(void)) {
    if ( block ) {
        [UIView animateWithDuration:0.3 animations:^{
            block();
        }];
    }
}

inline static NSString *_formatWithSec(NSInteger sec) {
    NSInteger seconds = sec % 60;
    NSInteger minutes = sec / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}




#pragma mark -

@interface CYVideoPlayer ()<CYVideoPlayerControlViewDelegate, CYSliderDelegate>

@property (nonatomic, strong, readonly) CYVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) CYVideoPlayerControlView *controlView;
@property (nonatomic, strong, readonly) CYVideoPlayerMoreSettingsView *moreSettingView;
@property (nonatomic, strong, readonly) CYVideoPlayerMoreSettingSecondaryView *moreSecondarySettingView;
@property (nonatomic, strong, readonly) CYOrentationObserver *orentation;
@property (nonatomic, strong, readonly) CYMoreSettingsFooterViewModel *moreSettingFooterViewModel;
@property (nonatomic, strong, readonly) CYVideoPlayerRegistrar *registrar;
@property (nonatomic, strong, readonly) CYVolBrigControl *volBrigControl;
@property (nonatomic, strong, readonly) CYPlayerGestureControl *gestureControl;
@property (nonatomic, strong, readonly) JDradualLoadingView *loadingView;


@property (nonatomic, assign, readwrite) CYVideoPlayerPlayState state;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSecondarySettingView;
@property (nonatomic, assign, readwrite) BOOL hiddenLeftControlView;
@property (nonatomic, assign, readwrite) BOOL userClickedPause;
@property (nonatomic, assign, readwrite) BOOL playOnCell;
@property (nonatomic, assign, readwrite) BOOL scrollIn;
@property (nonatomic, strong, readwrite) NSError *error;

- (void)_play;
- (void)_pause;

@end





#pragma mark - State

@interface CYVideoPlayer (State)

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

@implementation CYVideoPlayer (State)

- (CYTimerControl *)timerControl {
    CYTimerControl *timerControl = objc_getAssociatedObject(self, _cmd);
    if ( timerControl ) return timerControl;
    timerControl = [CYTimerControl new];
    objc_setAssociatedObject(self, _cmd, timerControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return timerControl;
}

- (void)_cancelDelayHiddenControl {
    [self.timerControl reset];
}

- (void)_delayHiddenControl {
    __weak typeof(self) _self = self;
    [self.timerControl start:^(CYTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == CYVideoPlayerPlayState_Pause ) return;
        _cyAnima(^{
            self.hideControl = YES;
        });
    }];
}

- (void)setLockScreen:(BOOL)lockScreen {
    if ( self.isLockedScrren == lockScreen )
    {
        return;
    }
    objc_setAssociatedObject(self, @selector(isLockedScrren), @(lockScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //外部调用
    if (self.lockscreen)
    {
        self.lockscreen(lockScreen);
    }
    
    [self _cancelDelayHiddenControl];
    _cyAnima(^{
        if ( lockScreen ) {
            [self _lockScreenState];
        }
        else {
            [self _unlockScreenState];
        }
    });
}

- (BOOL)isLockedScrren {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHideControl:(BOOL)hideControl {
//    if ( self.isHiddenControl == hideControl ) return;
    objc_setAssociatedObject(self, @selector(isHiddenControl), @(hideControl), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.timerControl reset];
    if ( hideControl ) [self _hideControlState];
    else {
        [self _showControlState];
        [self _delayHiddenControl];
    }
}

- (BOOL)isHiddenControl {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)_unknownState {
    // show
    _cyShowViews(@[self.presentView.placeholderImageView,]);
    
    // hidden
    _cyHiddenViews(@[self.controlView]);
    
    self.state = CYVideoPlayerPlayState_Unknown;
}

- (void)_prepareState {
    // show
    _cyShowViews(@[self.controlView,
                   self.presentView.placeholderImageView]);
    
    // hidden
    self.controlView.previewView.hidden = YES;
    _cyHiddenViews(@[
                     self.controlView.draggingProgressView,
                     self.controlView.topControlView.previewBtn,
                     self.controlView.leftControlView.lockBtn,
                     self.controlView.centerControlView.failedBtn,
                     self.controlView.centerControlView.replayBtn,
                     self.controlView.bottomControlView.playBtn,
                     self.controlView.bottomProgressSlider,
                     ]);
    
    if ( self.orentation.fullScreen ) {
        _cyShowViews(@[self.controlView.topControlView.moreBtn,]);
        self.hiddenLeftControlView = NO;
        if ( self.asset.hasBeenGeneratedPreviewImages ) {
            _cyShowViews(@[self.controlView.topControlView.previewBtn]);
        }
    }
    else {
        self.hiddenLeftControlView = YES;
        _cyHiddenViews(@[self.controlView.topControlView.moreBtn,
                         self.controlView.topControlView.previewBtn,]);
    }
    
    self.state = CYVideoPlayerPlayState_Prepare;
}

- (void)_playState {
    
    // show
    _cyShowViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    // hidden
    _cyHiddenViews(@[
                     self.presentView.placeholderImageView,
                     self.controlView.bottomControlView.playBtn,
                     self.controlView.centerControlView.replayBtn,
                     ]);
    
    self.state = CYVideoPlayerPlayState_Playing;
}

- (void)_pauseState {
    
    // show
    _cyShowViews(@[self.controlView.bottomControlView.playBtn]);
    
    // hidden
    _cyHiddenViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    self.state = CYVideoPlayerPlayState_Pause;
}

- (void)_playEndState {
    
    // show
    _cyShowViews(@[self.controlView.centerControlView.replayBtn,
                   self.controlView.bottomControlView.playBtn]);
    
    // hidden
    _cyHiddenViews(@[self.controlView.bottomControlView.pauseBtn]);
    
    
    self.state = CYVideoPlayerPlayState_PlayEnd;
}

- (void)_playFailedState {
    // show
    _cyShowViews(@[self.controlView.centerControlView.failedBtn]);
    
    // hidden
    _cyHiddenViews(@[self.controlView.centerControlView.replayBtn]);
    
    self.state = CYVideoPlayerPlayState_PlayFailed;
}

- (void)_lockScreenState {
    
    // show
    _cyShowViews(@[self.controlView.leftControlView.lockBtn]);
    
    // hidden
    _cyHiddenViews(@[self.controlView.leftControlView.unlockBtn]);
    self.hideControl = YES;
}

- (void)_unlockScreenState {
    
    // show
    _cyShowViews(@[self.controlView.leftControlView.unlockBtn]);
    self.hideControl = NO;
    
    // hidden
    _cyHiddenViews(@[self.controlView.leftControlView.lockBtn]);
    
}

- (void)_hideControlState {

    // show
    _cyShowViews(@[self.controlView.bottomProgressSlider]);
    
    // hidden
    self.controlView.previewView.hidden = YES;
    
    // transform hidden
    self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, -CYControlTopH);
    self.controlView.bottomControlView.transform = CGAffineTransformMakeTranslation(0, CYControlBottomH);

    if ( self.orentation.fullScreen ) {
        if ( self.isLockedScrren ) self.hiddenLeftControlView = NO;
        else self.hiddenLeftControlView = YES;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( self.orentation.fullScreen ) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    }
#pragma clang diagnostic pop
}

- (void)_showControlState {
    
    // hidden
    _cyHiddenViews(@[self.controlView.bottomProgressSlider]);
    self.controlView.previewView.hidden = YES;
    
    // transform show
    if ( self.playOnCell && !self.orentation.fullScreen ) {
        self.controlView.topControlView.transform = CGAffineTransformMakeTranslation(0, -CYControlTopH);
    }
    else {
        self.controlView.topControlView.transform = CGAffineTransformIdentity;
    }
    self.controlView.bottomControlView.transform = CGAffineTransformIdentity;
    
    self.hiddenLeftControlView = !self.orentation.fullScreen;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
#pragma clang diagnostic pop
}

@end


#pragma mark - CYVideoPlayer
#import "CYMoreSettingsFooterViewModel.h"

@implementation CYVideoPlayer {
    CYVideoPlayerPresentView *_presentView;
    CYVideoPlayerControlView *_controlView;
    CYVideoPlayerMoreSettingsView *_moreSettingView;
    CYVideoPlayerMoreSettingSecondaryView *_moreSecondarySettingView;
    CYOrentationObserver *_orentation;
    CYVideoPlayerView *_view;
    CYMoreSettingsFooterViewModel *_moreSettingFooterViewModel;
    CYVideoPlayerRegistrar *_registrar;
    CYVolBrigControl *_volBrigControl;
    JDradualLoadingView *_loadingView;
    CYPlayerGestureControl *_gestureControl;
}

+ (instancetype)sharedPlayer {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark

- (instancetype)init {
    self = [super init];
    if ( !self )  return nil;
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&error];
    if ( error ) {
        _cyErrorLog([NSString stringWithFormat:@"%@", error.userInfo]);
    }

    [self view];
    [self orentation];
    [self volBrig];
    [self settingPlayer:^(CYVideoPlayerSettings * _Nonnull settings) {
        [self resetSetting];
    }];
    [self registrar];
    
    // default values
    self.autoplay = YES;
    self.generatePreviewImages = YES;
    
    [self _unknownState];
    
    return self;
}

- (CYVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [CYVideoPlayerPresentView new];
    _presentView.clipsToBounds = YES;
    __weak typeof(self) _self = self;
    _presentView.readyForDisplay = ^(CYVideoPlayerPresentView * _Nonnull view) {
        if ( _self.asset.hasBeenGeneratedPreviewImages ) { return ; }
        if ( !_self.generatePreviewImages ) return;
        CGRect bounds = view.avLayer.videoRect;
        CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.4;
        CGFloat height = width * bounds.size.height / bounds.size.width;
        CGSize size = CGSizeMake(width, height);
        [_self.asset generatedPreviewImagesWithMaxItemSize:size completion:^(CYVideoPlayerAssetCarrier * _Nonnull asset, NSArray<CYVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
            if ( error ) {
                _cyErrorLog(@"Generate Preview Image Failed!");
            }
            else {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.orentation.fullScreen ) {
                    _cyAnima(^{
                        _cyShowViews(@[self.controlView.topControlView.previewBtn]);
                    });
                }
                self.controlView.previewView.previewImages = images;
            }
        }];
    };
    return _presentView;
}

- (CYVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [CYVideoPlayerControlView new];
    _controlView.clipsToBounds = YES;
    return _controlView;
}

- (UIView *)view {
    if ( _view ) return _view;
    _view = [CYVideoPlayerView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];
    [_presentView addSubview:self.controlView];
    [_controlView addSubview:self.moreSettingView];
    [_controlView addSubview:self.moreSecondarySettingView];
    [self gesturesHandleWithTargetView:_controlView];
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    _controlView.delegate = self;
    _controlView.bottomControlView.progressSlider.delegate = self;
    
    [_presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_presentView.superview);
    }];
    
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlView.superview);
    }];
    
    [_moreSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0);
        make.width.offset(MoreSettingWidth);
    }];
    
    [_moreSecondarySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_moreSettingView);
    }];
    
    _loadingView = [JDradualLoadingView new];
    _loadingView.lineWidth = 0.6;
    _loadingView.lineColor = [UIColor whiteColor];
    
    __weak typeof(self) _self = self;
    _view.setting = ^(CYVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.loadingView.lineWidth = setting.loadingLineWidth;
        self.loadingView.lineColor = setting.loadingLineColor;
    };
    
    return _view;
}

- (CYVideoPlayerMoreSettingsView *)moreSettingView {
    if ( _moreSettingView ) return _moreSettingView;
    _moreSettingView = [CYVideoPlayerMoreSettingsView new];
    _moreSettingView.backgroundColor = [UIColor blackColor];
    return _moreSettingView;
}

- (CYVideoPlayerMoreSettingSecondaryView *)moreSecondarySettingView {
    if ( _moreSecondarySettingView ) return _moreSecondarySettingView;
    _moreSecondarySettingView = [CYVideoPlayerMoreSettingSecondaryView new];
    _moreSecondarySettingView.backgroundColor = [UIColor blackColor];
    _moreSettingFooterViewModel = [CYMoreSettingsFooterViewModel new];
    __weak typeof(self) _self = self;
    _moreSettingFooterViewModel.needChangeBrightness = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.volBrigControl.brightness = brightness;
    };
    
    _moreSettingFooterViewModel.needChangePlayerRate = ^(float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.asset ) return;
        self.rate = rate;
    };
    
    _moreSettingFooterViewModel.needChangeVolume = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.volBrigControl.volume = volume;
    };
    
    _moreSettingFooterViewModel.initialVolumeValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrigControl.volume;
    };
    
    _moreSettingFooterViewModel.initialBrightnessValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
        return self.volBrigControl.brightness;
    };
    
    _moreSettingFooterViewModel.initialPlayerRateValue = ^float{
        __strong typeof(_self) self = _self;
        if ( !self ) return 0;
       return self.asset.player.rate;
    };
    
    _moreSettingView.footerViewModel = _moreSettingFooterViewModel;
    return _moreSecondarySettingView;
}

- (void)setHiddenMoreSettingView:(BOOL)hiddenMoreSettingView {
    if ( hiddenMoreSettingView == _hiddenMoreSettingView ) return;
    _hiddenMoreSettingView = hiddenMoreSettingView;
    if ( hiddenMoreSettingView ) {
        _moreSettingView.transform = CGAffineTransformMakeTranslation(MoreSettingWidth, 0);
    }
    else {
        _moreSettingView.transform = CGAffineTransformIdentity;
    }
}

- (void)setHiddenMoreSecondarySettingView:(BOOL)hiddenMoreSecondarySettingView {
    if ( hiddenMoreSecondarySettingView == _hiddenMoreSecondarySettingView ) return;
    _hiddenMoreSecondarySettingView = hiddenMoreSecondarySettingView;
    if ( hiddenMoreSecondarySettingView ) {
        _moreSecondarySettingView.transform = CGAffineTransformMakeTranslation(MoreSettingWidth, 0);
    }
    else {
        _moreSecondarySettingView.transform = CGAffineTransformIdentity;
    }
}

- (void)setHiddenLeftControlView:(BOOL)hiddenLeftControlView {
    if ( hiddenLeftControlView == _hiddenLeftControlView ) return;
    _hiddenLeftControlView = hiddenLeftControlView;
    if ( _hiddenLeftControlView )
    {
        self.controlView.leftControlView.transform = CGAffineTransformMakeTranslation(-CYControlLeftH, 0);
    }
    else
    {
        self.controlView.leftControlView.transform =  CGAffineTransformIdentity;
    }
}

- (CYOrentationObserver *)orentation
{
    if (_orentation)
    {
        return _orentation;
    }
    _orentation = [[CYOrentationObserver alloc] initWithTarget:self.presentView container:self.view];
    __weak typeof(self) _self = self;
    _orentation.orientationChanged = ^(CYOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self )
        {
            return;
        }
        self.hideControl = NO;
        _cyAnima(^{
            self.controlView.previewView.hidden = YES;
            self.hiddenMoreSecondarySettingView = YES;
            self.hiddenMoreSettingView = YES;
            self.hiddenLeftControlView = !observer.isFullScreen;
            if ( observer.isFullScreen ) {
                _cyShowViews(@[self.controlView.topControlView.moreBtn,]);
                if ( self.asset.hasBeenGeneratedPreviewImages ) {
                    _cyShowViews(@[self.controlView.topControlView.previewBtn]);
                }
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.offset(0);
                    make.height.equalTo(self.controlView.superview);
                    make.width.equalTo(self.controlView.mas_height).multipliedBy(16.0 / 9.0);
                }];
            }
            else {
                _cyHiddenViews(@[self.controlView.topControlView.moreBtn,
                                 self.controlView.topControlView.previewBtn,]);
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.controlView.superview);
                }];
            }
        });//_cyAnima(^{})
    };//orientationChanged
    
    _orentation.rotationCondition = ^BOOL(CYOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        switch (self.state) {
            case CYVideoPlayerPlayState_Unknown:
            case CYVideoPlayerPlayState_Prepare:
            case CYVideoPlayerPlayState_PlayFailed: return NO;
            default: break;
        }
        if ( self.playOnCell && !self.scrollIn ) return NO;
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScrren ) return NO;
        return YES;
    };
    return _orentation;
}

- (CYVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [CYVideoPlayerRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(CYVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _pause];
        self.lockScreen = YES;
    };
    
    _registrar.didBecomeActive = ^(CYVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.lockScreen = NO;
        if ( !self.userClickedPause ) [self play];
    };
    
    _registrar.oldDeviceUnavailable = ^(CYVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.userClickedPause ) [self play];
    };
    
//    _registrar.categoryChange = ^(CYVideoPlayerRegistrar * _Nonnull registrar) {
//        __strong typeof(_self) self = _self;
//        if ( !self ) return;
//
//    };
    
    return _registrar;
}

- (CYVolBrigControl *)volBrig {
    if ( _volBrigControl ) return _volBrigControl;
    _volBrigControl  = [CYVolBrigControl new];
    __weak typeof(self) _self = self;
    _volBrigControl.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.volumeChanged ) self.moreSettingFooterViewModel.volumeChanged(volume);
    };
    
    _volBrigControl.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.moreSettingFooterViewModel.brightnessChanged ) self.moreSettingFooterViewModel.brightnessChanged(self.volBrigControl.brightness);
    };
    
    return _volBrigControl;
}

- (void)gesturesHandleWithTargetView:(UIView *)targetView {
    
    _gestureControl = [[CYPlayerGestureControl alloc] initWithTargetView:targetView];

    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(CYPlayerGestureControl * _Nonnull control, UIGestureRecognizer *gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( self.isLockedScrren ) return NO;
        CGPoint point = [gesture locationInView:gesture.view];
        if ( CGRectContainsPoint(self.moreSettingView.frame, point) ||
             CGRectContainsPoint(self.moreSecondarySettingView.frame, point) ||
             CGRectContainsPoint(self.controlView.previewView.frame, point) ) {
            return NO;
        }
        if ( [gesture isKindOfClass:[UIPanGestureRecognizer class]] &&
             self.playOnCell &&
            !self.orentation.fullScreen ) return NO;
        else return YES;
    };
    
    _gestureControl.singleTapped = ^(CYPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        _cyAnima(^{
            if ( !self.hiddenMoreSettingView ) {
                self.hiddenMoreSettingView = YES;
            }
            else if ( !self.hiddenMoreSecondarySettingView ) {
                self.hiddenMoreSecondarySettingView = YES;
            }
            else {
                self.hideControl = !self.isHiddenControl;
            }
        });
    };
    
    _gestureControl.doubleTapped = ^(CYPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (self.state) {
            case CYVideoPlayerPlayState_Unknown:
            case CYVideoPlayerPlayState_Prepare:
                break;
            case CYVideoPlayerPlayState_Buffing:
            case CYVideoPlayerPlayState_Playing: {
                [self pause];
            }
                break;
            case CYVideoPlayerPlayState_Pause:
            case CYVideoPlayerPlayState_PlayEnd: {
                [self play];
            }
                break;
            case CYVideoPlayerPlayState_PlayFailed:
                break;
        }
    };
    
    static __weak UIView *target = nil;
    _gestureControl.beganPan = ^(CYPlayerGestureControl * _Nonnull control, CYPanDirection direction, CYPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case CYPanDirection_H: {
                [self _pause];
                _cyAnima(^{
                    _cyShowViews(@[self.controlView.draggingProgressView]);
                });
                self.controlView.draggingProgressView.progressSlider.value = self.asset.progress;
                self.controlView.draggingProgressView.progressLabel.text = _formatWithSec(self.asset.currentTime);
                self.hideControl = YES;
            }
                break;
            case CYPanDirection_V: {
                switch (location) {
                    case CYPanLocation_Right: break;
                    case CYPanLocation_Left: {
                        [[UIApplication sharedApplication].keyWindow addSubview:self.volBrigControl.brightnessView];
                        [self.volBrigControl.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_offset(CGSizeMake(155, 155));
                            make.center.equalTo([UIApplication sharedApplication].keyWindow);
                        }];
                        self.volBrigControl.brightnessView.transform = self.controlView.superview.transform;
                        _cyAnima(^{
                            _cyShowViews(@[self.volBrigControl.brightnessView]);
                        });
                    }
                        break;
                    case CYPanLocation_Unknown: break;
                }
            }
                break;
            case CYPanDirection_Unknown:
                break;
        }
    };
    
    _gestureControl.changedPan = ^(CYPlayerGestureControl * _Nonnull control, CYPanDirection direction, CYPanLocation location, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case CYPanDirection_H: {
                self.controlView.draggingProgressView.progressSlider.value += translate.x * 0.003;
                self.controlView.draggingProgressView.progressLabel.text =  _formatWithSec(self.asset.duration * self.controlView.draggingProgressView.progressSlider.value);
            }
                break;
            case CYPanDirection_V: {
                switch (location) {
                    case CYPanLocation_Left: {
                        CGFloat value = self.volBrigControl.brightness - translate.y * 0.006;
                        if ( value < 1.0 / 16 ) value = 1.0 / 16;
                        self.volBrigControl.brightness = value;
                    }
                        break;
                    case CYPanLocation_Right: {
                        CGFloat value = translate.y * 0.012;
                        self.volBrigControl.volume -= value;
                    }
                        break;
                    case CYPanLocation_Unknown: break;
                }
            }
                break;
            default:
                break;
        }
    };
    
    _gestureControl.endedPan = ^(CYPlayerGestureControl * _Nonnull control, CYPanDirection direction, CYPanLocation location) {
        switch ( direction ) {
            case CYPanDirection_H:{
                _cyAnima(^{
                    _cyHiddenViews(@[_self.controlView.draggingProgressView]);
                });
                [_self jumpedToTime:_self.controlView.draggingProgressView.progressSlider.value * _self.asset.duration completionHandler:^(BOOL finished) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self play];
                }];
            }
                break;
            case CYPanDirection_V:{
                if ( location == CYPanLocation_Left ) {
                    _cyAnima(^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        _cyHiddenViews(@[self.volBrigControl.brightnessView]);
                    });
                }
            }
                break;
            case CYPanDirection_Unknown: break;
        }
        target = nil;
    };
}

#pragma mark ======================================================

- (void)sliderWillBeginDragging:(CYSlider *)slider {
    switch (slider.tag) {
        case CYVideoPlaySliderTag_Progress: {
            [self _pause];
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
            _cyAnima(^{
                _cyShowViews(@[self.controlView.draggingProgressView]);
            });
            [self _cancelDelayHiddenControl];
            self.controlView.draggingProgressView.progressSlider.value = slider.value;
            self.controlView.draggingProgressView.progressLabel.text = _formatWithSec(currentTime);
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidDrag:(CYSlider *)slider {
    switch (slider.tag) {
        case CYVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            [self _refreshingTimeLabelWithCurrentTime:currentTime duration:self.asset.duration];
            
            self.controlView.draggingProgressView.progressSlider.value = slider.value;
            self.controlView.draggingProgressView.progressLabel.text =  _formatWithSec(self.asset.duration * slider.value);
        }
            break;
            
        default:
            break;
    }
}

- (void)sliderDidEndDragging:(CYSlider *)slider {
    switch (slider.tag) {
        case CYVideoPlaySliderTag_Progress: {
            NSInteger currentTime = slider.value * self.asset.duration;
            __weak typeof(self) _self = self;
            [self jumpedToTime:currentTime completionHandler:^(BOOL finished) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self play];
                [self _delayHiddenControl];
                _cyAnima(^{
                    _cyHiddenViews(@[self.controlView.draggingProgressView]);
                });
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ======================================================

- (void)controlView:(CYVideoPlayerControlView *)controlView clickedBtnTag:(CYVideoPlayControlViewTag)tag {
    switch (tag) {
        case CYVideoPlayControlViewTag_Back: {
            if ( self.orentation.isFullScreen ) {
                if ( self.disableRotation ) return;
                else [self.orentation _changeOrientation];
            }
            else {
                if ( self.clickedBackEvent ) self.clickedBackEvent(self);
            }
        }
            break;
        case CYVideoPlayControlViewTag_Full: {
            [self.orentation _changeOrientation];
        }
            break;
            
        case CYVideoPlayControlViewTag_Play: {
            [self play];
        }
            break;
        case CYVideoPlayControlViewTag_Pause: {
            [self pause];
        }
            break;
        case CYVideoPlayControlViewTag_Replay: {
            _cyAnima(^{
                if ( !self.isLockedScrren ) self.hideControl = NO;
            });
            [self play];
        }
            break;
        case CYVideoPlayControlViewTag_Preview: {
            [self _cancelDelayHiddenControl];
            _cyAnima(^{
                self.controlView.previewView.hidden = !self.controlView.previewView.isHidden;
            });
        }
            break;
        case CYVideoPlayControlViewTag_Lock: {
            // 解锁
            self.lockScreen = NO;
        }
            break;
        case CYVideoPlayControlViewTag_Unlock: {
            // 锁屏
            self.lockScreen = YES;
            [self showTitle:@"已锁定"];
        }
            break;
        case CYVideoPlayControlViewTag_LoadFailed: {
            self.asset = [[CYVideoPlayerAssetCarrier alloc] initWithAssetURL:self.asset.assetURL beginTime:self.asset.beginTime scrollView:self.asset.scrollView indexPath:self.asset.indexPath superviewTag:self.asset.superviewTag];
        }
            break;
        case CYVideoPlayControlViewTag_More: {
            _cyAnima(^{
                self.hiddenMoreSettingView = NO;
                self.hideControl = YES;
            });
        }
            break;
    }
}

- (void)controlView:(CYVideoPlayerControlView *)controlView didSelectPreviewItem:(CYVideoPreviewModel *)item {
    [self _pause];
    __weak typeof(self) _self = self;
    [self seekToTime:item.localTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
}

#pragma mark

- (void)_itemPrepareToPlay {
    [self _startLoading];
    self.hideControl = YES;
    self.userClickedPause = NO;
    self.hiddenMoreSettingView = YES;
    self.hiddenMoreSecondarySettingView = YES;
    self.controlView.bottomProgressSlider.value = 0;
    self.controlView.bottomProgressSlider.bufferProgress = 0;
    self.rate = 1;
    if ( self.moreSettingFooterViewModel.volumeChanged ) {
        self.moreSettingFooterViewModel.volumeChanged(self.volBrigControl.volume);
    }
    if ( self.moreSettingFooterViewModel.brightnessChanged ) {
        self.moreSettingFooterViewModel.brightnessChanged(self.volBrigControl.brightness);
    }
    [self _prepareState];
}

- (void)_itemPlayFailed {
    [self _stopLoading];
    [self _playFailedState];
    self.error = self.asset.playerItem.error;
    _cyErrorLog(self.error);
}

- (void)_itemReadyToPlay {
    _cyAnima(^{
        self.hideControl = NO;
    });
    if ( 0 != self.asset.beginTime && !self.asset.jumped ) {
        __weak typeof(self) _self = self;
        [self jumpedToTime:self.asset.beginTime completionHandler:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.asset.jumped = YES;
            if ( self.autoplay ) [self play];
        }];
    }
    else {
        if ( self.autoplay && !self.userClickedPause ) [self play];
    }
}

- (void)_refreshingTimeLabelWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomControlView.currentTimeLabel.text = _formatWithSec(currentTime);
    self.controlView.bottomControlView.durationTimeLabel.text = _formatWithSec(duration);
}

- (void)_refreshingTimeProgressSliderWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.controlView.bottomProgressSlider.value = self.controlView.bottomControlView.progressSlider.value = currentTime / duration;
}

- (void)_itemPlayEnd {
    [self jumpedToTime:0 completionHandler:nil];
    [self _playEndState];
}

- (void)_play {
    [self _stopLoading];
    [self.asset.player play];
}

- (void)_pause {
    [self.asset.player pause];
}

static BOOL _isLoading;
- (void)_startLoading {
    if ( _isLoading ) return;
    _isLoading = YES;
    [_controlView addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.height.equalTo(_loadingView.superview).multipliedBy(0.2);
        make.width.equalTo(_loadingView.mas_height);
    }];
    [_loadingView startAnimation];
}

- (void)_stopLoading {
    _isLoading = NO;
    [_loadingView stopAnimation];
    [_loadingView removeFromSuperview];
}

- (void)_buffering {
    if ( self.state == CYVideoPlayerPlayState_PlayEnd ) return;
    if ( self.userClickedPause ) return;
    
    [self _startLoading];
    [self _pause];
    self.state = CYVideoPlayerPlayState_Buffing;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( !self.asset.playerItem.isPlaybackLikelyToKeepUp ) {
            [self _buffering];
        }
        else {
            [self _stopLoading];
            if ( !self.userClickedPause ) [self play];
        }
    });
}

@end





#pragma mark -

@implementation CYVideoPlayer (Setting)

- (void)playWithURL:(NSURL *)playURL {
    [self playWithURL:playURL jumpedToTime:0];
}

// unit: sec.
- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time {
    self.asset = [[CYVideoPlayerAssetCarrier alloc] initWithAssetURL:playURL beginTime:time];
}

- (void)setAssetURL:(NSURL *)assetURL {
    [self playWithURL:assetURL jumpedToTime:0];
}

- (NSURL *)assetURL {
    return self.asset.assetURL;
}

- (void)setAsset:(CYVideoPlayerAssetCarrier *)asset {
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.asset = asset;
    _controlView.asset = asset;
    
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    
    asset.playerItemStateChanged = ^(CYVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == CYVideoPlayerPlayState_PlayEnd ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case AVPlayerItemStatusUnknown: break;
                case AVPlayerItemStatusFailed: {
                    [self _itemPlayFailed];
                }
                    break;
                case AVPlayerItemStatusReadyToPlay: {
                    [self performSelector:@selector(_itemReadyToPlay) withObject:nil afterDelay:1];
                }
                    break;
            }
        });

    };
    
    asset.playTimeChanged = ^(CYVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _refreshingTimeProgressSliderWithCurrentTime:currentTime duration:duration];
        [self _refreshingTimeLabelWithCurrentTime:currentTime duration:duration];
    };
    
    asset.playDidToEnd = ^(CYVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _itemPlayEnd];
    };
    
    asset.loadedTimeProgress = ^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.controlView.bottomControlView.progressSlider.bufferProgress = progress;
    };
    
    asset.beingBuffered = ^(BOOL state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _buffering];
    };
    
    asset.deallocCallBlock = ^(CYVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.view.alpha = 1;
    };
    
    if ( asset.indexPath ) {
        self.playOnCell = YES;
        self.scrollIn = YES;
    }
    else {
        self.playOnCell = NO;
        self.scrollIn = NO;
    }
    
    asset.scrollViewDidScroll = ^(CYVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [asset.scrollView isKindOfClass:[UITableView class]] ) {
            UITableView *tableView = (UITableView *)asset.scrollView;
            __block BOOL visable = NO;
            [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( [obj compare:self.asset.indexPath] == NSOrderedSame ) {
                    visable = YES;
                    *stop = YES;
                }
            }];
            if ( visable ) {
                if ( YES == self.scrollIn ) return;
                /// 滑入时
                self.scrollIn = YES;
                self.view.alpha = 1;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.asset.indexPath];
                UIView *superview = [cell.contentView viewWithTag:self.asset.superviewTag];
                if ( superview && self.view.superview != superview ) {
                    [self.view removeFromSuperview];
                    [superview addSubview:self.view];
                    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view.superview);
                    }];
                }
            }
            else {
                if ( NO == self.scrollIn ) return;
                /// 滑出时
                self.scrollIn = NO;
                self.view.alpha = 0.001;
                [self pause];
                self.hideControl = NO;
            }
        }
        else if ( [asset.scrollView isKindOfClass:[UICollectionView class]] ) {
            UICollectionView *collectionView = (UICollectionView *)asset.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.asset.indexPath];
            if ( [collectionView.visibleCells containsObject:cell] ) {
                if ( YES == self.scrollIn ) return;
                /// 滑入时
                self.scrollIn = YES;
                self.view.alpha = 1;
                [self.view removeFromSuperview];
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.asset.indexPath];
                UIView *superview = [cell.contentView viewWithTag:self.asset.superviewTag];
                if ( superview && self.view.superview != superview ) {
                    [self.view removeFromSuperview];
                    [superview addSubview:self.view];
                    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view.superview);
                    }];
                }
            }
            else {
                if ( NO == self.scrollIn ) return;
                /// 滑出时
                self.scrollIn = NO;
                self.view.alpha = 0.001;
                [self pause];
                self.hideControl = NO;
            }
        }
    };
}

//static __weak UIView *tmpView = nil;
//- (UIView *)_getSuperviewWithContentView:(UIView *)contentView tag:(NSInteger)tag {
//    if ( contentView.tag == tag ) return contentView;
//    
//    [self _searchingWithView:contentView tag:tag];
//    UIView *target = tmpView;
//    tmpView = nil;
//    return target;
//}
//
//- (void)_searchingWithView:(UIView *)view tag:(NSInteger)tag {
//    if ( tmpView ) return;
//    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ( obj.tag == tag ) {
//            *stop = YES;
//            tmpView = obj;
//        }
//        else {
//            [self _searchingWithView:obj tag:tag];
//        }
//    }];
//    return;
//}

- (CYVideoPlayerAssetCarrier *)asset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMoreSettings:(NSArray<CYVideoPlayerMoreSetting *> *)moreSettings {
    objc_setAssociatedObject(self, @selector(moreSettings), moreSettings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableSet<CYVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(CYVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:obj container:moreSettingsM];
    }];
    
    [moreSettingsM enumerateObjectsUsingBlock:^(CYVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self dressSetting:obj];
    }];
    self.moreSettingView.moreSettings = moreSettings;
}

- (void)addSetting:(CYVideoPlayerMoreSetting *)setting container:(NSMutableSet<CYVideoPlayerMoreSetting *> *)moreSttingsM {
    [moreSttingsM addObject:setting];
    if ( !setting.showTowSetting ) return;
    [setting.twoSettingItems enumerateObjectsUsingBlock:^(CYVideoPlayerMoreSettingSecondary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:(CYVideoPlayerMoreSetting *)obj container:moreSttingsM];
    }];
}

- (void)dressSetting:(CYVideoPlayerMoreSetting *)setting {
    if ( !setting.clickedExeBlock ) return;
    void(^clickedExeBlock)(CYVideoPlayerMoreSetting *model) = [setting.clickedExeBlock copy];
    __weak typeof(self) _self = self;
    if ( setting.isShowTowSetting ) {
        setting.clickedExeBlock = ^(CYVideoPlayerMoreSetting * _Nonnull model) {
            clickedExeBlock(model);
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.moreSecondarySettingView.twoLevelSettings = model;
            _cyAnima(^{
                self.hiddenMoreSettingView = YES;
                self.hiddenMoreSecondarySettingView = NO;
            });
        };
        return;
    }
    
    setting.clickedExeBlock = ^(CYVideoPlayerMoreSetting * _Nonnull model) {
        clickedExeBlock(model);
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        _cyAnima(^{
            self.hiddenMoreSettingView = YES;
            if ( !model.isShowTowSetting ) self.hiddenMoreSecondarySettingView = YES;
        });
    };
}

- (NSArray<CYVideoPlayerMoreSetting *> *)moreSettings {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)settingPlayer:(void (^)(CYVideoPlayerSettings * _Nonnull))block {
    if ( block ) block([self settings]);
    [[NSNotificationCenter defaultCenter] postNotificationName:CYSettingsPlayerNotification object:[self settings]];
}

- (CYVideoPlayerSettings *)settings {
    CYVideoPlayerSettings *setting = objc_getAssociatedObject(self, _cmd);
    if ( setting ) return setting;
    setting = [CYVideoPlayerSettings new];
    objc_setAssociatedObject(self, _cmd, setting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return setting;
}

- (void)resetSetting {
    CYVideoPlayerSettings *setting = self.settings;
    setting.backBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_back"];
    setting.moreBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_more"];
    setting.previewBtnImage = [CYVideoPlayerResources imageNamed:@""];
    setting.playBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_play"];
    setting.pauseBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_pause"];
    setting.fullBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_fullscreen"];
    setting.lockBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_lock"];
    setting.unlockBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_unlock"];
    setting.replayBtnImage = [CYVideoPlayerResources imageNamed:@"cy_video_player_replay"];
    setting.replayBtnTitle = @"重播";
    setting.progress_traceColor = [UIColor orangeColor];
    setting.progress_bufferColor = [UIColor colorWithWhite:0 alpha:0.2];
    setting.progress_trackColor =  [UIColor whiteColor];
    setting.progress_traceHeight = 3;
    setting.more_traceColor = [UIColor greenColor];
    setting.more_trackColor = [UIColor whiteColor];
    setting.more_traceHeight = 5;
    setting.loadingLineColor = [UIColor whiteColor];
    setting.loadingLineWidth = 1;
}

- (void)setPlaceholder:(UIImage *)placeholder {
    self.presentView.placeholderImageView.image = placeholder;
}

- (void)setAutoplay:(BOOL)autoplay {
    objc_setAssociatedObject(self, @selector(isAutoplay), @(autoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setGeneratePreviewImages:(BOOL)generatePreviewImages {
    objc_setAssociatedObject(self, @selector(generatePreviewImages), @(generatePreviewImages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)generatePreviewImages {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setClickedBackEvent:(void (^)(CYVideoPlayer *player))clickedBackEvent {
    objc_setAssociatedObject(self, @selector(clickedBackEvent), clickedBackEvent, OBJC_ASSOCIATION_COPY);
}

- (void (^)(CYVideoPlayer * _Nonnull))clickedBackEvent {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisableRotation:(BOOL)disableRotation {
    objc_setAssociatedObject(self, @selector(disableRotation), @(disableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
} 

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    objc_setAssociatedObject(self, @selector(videoGravity), videoGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)_cleanSetting {
    [self.asset cancelPreviewImagesGeneration];
    self.asset = nil;
    self.rate = 1;
}

- (void)setRate:(float)rate {
    if ( self.rate == rate ) return;
    objc_setAssociatedObject(self, @selector(rate), @(rate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.asset.player.rate = rate;
    self.userClickedPause = NO;
    _cyAnima(^{
        [self _playState];
    });
    if ( self.moreSettingFooterViewModel.playerRateChanged )
        self.moreSettingFooterViewModel.playerRateChanged(rate);
    if ( self.rateChanged ) self.rateChanged(self);
}

- (float)rate {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void (^)(CYVideoPlayer * _Nonnull))rateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRateChanged:(void (^)(CYVideoPlayer * _Nonnull))rateChanged {
    objc_setAssociatedObject(self, @selector(rateChanged), rateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end





#pragma mark -

@implementation CYVideoPlayer (Control)

- (BOOL)play {
    if ( !self.asset ) return NO;
    self.userClickedPause = NO;
    _cyAnima(^{
        [self _playState];
    });
    [self _play];
    return YES;
}

- (BOOL)pause {
    if ( !self.asset ) return NO;
    self.userClickedPause = YES;
    _cyAnima(^{
        [self _pauseState];
    });
    [self _pause];
    if ( !self.playOnCell || self.orentation.fullScreen ) [self showTitle:@"已暂停"];
    return YES;
}

- (void)stop {
    [self _pause];
    [self _cleanSetting];
    
    _cyAnima(^{
        [self _unknownState];
    });
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [self _startLoading];
    __weak typeof(self) _self = self;
    [self.asset.playerItem seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _stopLoading];
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (UIImage *)screenshot {
    return [self.asset screenshot];
}

- (NSTimeInterval)currentTime {
    return self.asset.currentTime;
}

- (void)stopRotation {
    self.disableRotation = YES;
}

- (void)enableRotation {
    self.disableRotation = NO;
}

- (void)setLockscreen:(LockScreen)lockscreen
{
    objc_setAssociatedObject(self, @selector(lockscreen), lockscreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LockScreen)lockscreen
{
    return objc_getAssociatedObject(self, _cmd);
}

@end


@implementation CYVideoPlayer (Prompt)

- (CYPrompt *)prompt {
    CYPrompt *prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt ) return prompt;
    prompt = [CYPrompt promptWithPresentView:self.presentView];
    objc_setAssociatedObject(self, _cmd, prompt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return prompt;
}

- (void)showTitle:(NSString *)title {
    [self showTitle:title duration:1];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self.prompt showTitle:title duration:duration];
}

- (void)hiddenTitle {
    [self.prompt hidden];
}

@end
