//
//  CYVideoPlayerSettings.h
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/9/25.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSNotificationName const CYSettingsPlayerNotification;

@class UIImage, UIColor;

@interface CYVideoPlayerSettings : NSObject
// MARK: btns
@property (nonatomic, strong, readwrite) UIImage *backBtnImage;
@property (nonatomic, strong, readwrite) UIImage *playBtnImage;
@property (nonatomic, strong, readwrite) UIImage *pauseBtnImage;
@property (nonatomic, strong, readwrite) UIImage *replayBtnImage;
@property (nonatomic, strong, readwrite) NSString *replayBtnTitle;
@property (nonatomic, assign, readwrite) float replayBtnFontSize;
@property (nonatomic, strong, readwrite) UIImage *fullBtnImage_nor;
@property (nonatomic, strong, readwrite) UIImage *fullBtnImage_sel;
@property (nonatomic, strong, readwrite) UIImage *previewBtnImage;
@property (nonatomic, strong, readwrite) UIImage *moreBtnImage;
@property (nonatomic, copy, readwrite)   NSString *title;
@property (nonatomic, strong, readwrite) UIImage *lockBtnImage;
@property (nonatomic, strong, readwrite) UIImage *unlockBtnImage;

// MARK: progress slider
/// 轨迹
@property (nonatomic, strong, readwrite) UIColor *progress_traceColor;
/// 轨道
@property (nonatomic, strong, readwrite) UIColor *progress_trackColor;
/// 拇指图片
@property (nonatomic, strong, readwrite) UIImage *progress_thumbImage;
@property (nonatomic, strong, readwrite) UIImage *progress_thumbImage_nor;
@property (nonatomic, strong, readwrite) UIImage *progress_thumbImage_sel;
/// 缓冲颜色
@property (nonatomic, strong, readwrite) UIColor *progress_bufferColor;
/// 轨道高度
@property (nonatomic, assign, readwrite) float progress_traceHeight;

// MARK:  more slider
/// 轨迹
@property (nonatomic, strong, readwrite) UIColor *more_traceColor;
/// 轨道
@property (nonatomic, strong, readwrite) UIColor *more_trackColor;
/// 轨道高度
@property (nonatomic, assign, readwrite) float more_trackHeight;

// MARK: Loading
@property (nonatomic, strong, readwrite) UIColor *loadingLineColor;

// MARK: Control
@property (nonatomic, assign, readwrite) BOOL enableProgressControl;


+ (instancetype)sharedVideoPlayerSettings;

@end
