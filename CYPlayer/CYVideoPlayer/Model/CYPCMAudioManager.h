//
//  CYPCMAudioManager.h
//  CYPlayer
//
//  Created by 黄威 on 2018/8/24.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<AVFoundation/AVFoundation.h>
#import "CYOpenALPlayer.h"

@class CYPCMAudioManager;

//typedef void(^CYPCMAudioManageriNeedBu)(<#arguments#>);

@protocol CYPCMAudioManagerDelegate<NSObject>

@optional
- (void)audioManager:(CYPCMAudioManager *)audioManager audioRouteChangeListenerCallback:(NSNotification*)notification;

@end

@interface CYPCMAudioManager : NSObject<AVAudioPlayerDelegate>


+ (CYPCMAudioManager*) audioManager;

@property (nonatomic, weak) id<CYPCMAudioManagerDelegate> delegate;

@property (nonatomic,strong) CYOpenALPlayer *player;

@property (readonly) NSInteger          numOutputChannels;
@property (readonly) double             samplingRate;

/**
 * 初始化播放器，并传入音频的本地路径
 *
 * path   音频pcm文件完整路径
 * sample 音频pcm文件采样率，支持8000和16000两种
 ****/
-(void)setFilePath:(NSString *)path;


/**
 * 初始化播放器，并传入音频数据
 *
 * data   音频数据
 * sample 音频pcm文件采样率，支持8000和16000两种
 ****/
-(void)setData:(NSData *)data;


/**
 停止并清除缓存
 */
- (void)stopAndCleanBuffer;

/**
 停止播放
 ****/
- (void)stop;



/**
 是否在播放状态
 ****/
@property (nonatomic,assign) BOOL isPlaying;

@end
