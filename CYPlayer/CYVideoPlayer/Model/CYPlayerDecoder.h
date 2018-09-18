//
//  CYPlayerDecoder.h
//  cyplayer
//
//  Created by yellowei on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/yellowei/cyplayer
//  this file is part of CYPlayer
//  CYPlayer is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#define CYPlayerDecoderMaxFPS 30
extern NSInteger CYPlayerDecoderConCurrentThreadCount;// range: 1 - 5

extern NSInteger CYPlayerDecoderMaxFPS;

extern NSString * cyplayerErrorDomain;

typedef BOOL(^CYPlayerDecoderInterruptCallback)(void);

typedef enum {
    
    cyPlayerErrorNone,
    cyPlayerErrorOpenFile,
    cyPlayerErrorStreamInfoNotFound,
    cyPlayerErrorStreamNotFound,
    cyPlayerErrorCodecNotFound,
    cyPlayerErrorOpenCodec,
    cyPlayerErrorAllocateFrame,
    cyPlayerErroSetupScaler,
    cyPlayerErroReSampler,
    cyPlayerErroUnsupported,
    cyPlayerErroOpenFilter
    
} cyPlayerError;

typedef enum {
    
    CYPlayerFrameTypeAudio,
    CYPlayerFrameTypeVideo,
    CYPlayerFrameTypeArtwork,
    CYPlayerFrameTypeSubtitle,
    
} CYPlayerFrameType;

typedef enum {
        
    CYVideoFrameFormatRGB,
    CYVideoFrameFormatYUV,
    
} CYVideoFrameFormat;

typedef enum {
    
    CYPlayerFilter_FILTER_NULL,
    CYPlayerFilter_FILTER_MIRROR,
    CYPlayerFilter_FILTER_WATERMARK,
    CYPlayerFilter_FILTER_NEGATE,
    CYPlayerFilter_FILTER_EDGE,
    CYPlayerFilter_FILTER_SPLIT4,
    CYPlayerFilter_FILTER_VINTAGE,
    CYPlayerFilter_FILTER_BRIGHTNESS,
    CYPlayerFilter_FILTER_CONTRAST,
    CYPlayerFilter_FILTER_SATURATION,
    CYPlayerFilter_FILTER_EQ,
    CYPlayerFilter_FILTER_TEST

} CYPlayerFilterType;

@interface CYPlayerFrame : NSObject
@property (readonly, nonatomic) CYPlayerFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface CYAudioFrame : CYPlayerFrame
@property (readonly, nonatomic, strong) NSData *samples;
@end

@interface CYVideoFrame : CYPlayerFrame
@property (readonly, nonatomic) CYVideoFrameFormat format;
@property (readonly, nonatomic) NSUInteger width;
@property (readonly, nonatomic) NSUInteger height;
@end

@interface CYVideoFrameRGB : CYVideoFrame
@property (readonly, nonatomic) NSUInteger linesize;
@property (readonly, nonatomic, strong) NSData *rgb;
- (UIImage *) asImage;
@end

@interface CYVideoFrameYUV : CYVideoFrame
@property (readonly, nonatomic, strong) NSData *luma;
@property (readonly, nonatomic, strong) NSData *chromaB;
@property (readonly, nonatomic, strong) NSData *chromaR;
@end

@interface CYArtworkFrame : CYPlayerFrame
@property (readonly, nonatomic, strong) NSData *picture;
- (UIImage *) asImage;
@end

@interface CYSubtitleFrame : CYPlayerFrame
@property (readonly, nonatomic, strong) NSString *text;
@end


typedef enum {
    
    CYVideoDecodeTypeNone = 0,
    CYVideoDecodeTypeVideo = 1 << 0,
    CYVideoDecodeTypeAudio = 1 << 1
    
} CYVideoDecodeType;


typedef void(^CYPlayerCompeletionDecode)(NSArray<CYPlayerFrame *> * frames, BOOL compeleted);
typedef void(^CYPlayerCompeletionThread)(NSArray<CYPlayerFrame *> * frames);

@interface CYPlayerDecoder : NSObject

@property (readonly, nonatomic, strong) NSString *path;
@property (readonly, nonatomic) BOOL isEOF;
@property (readwrite,nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat targetPosition;//每次快进重置这个值, 目的是为了把上次没快进完成的线程结束掉
@property (readonly, nonatomic) CGFloat duration;
@property (readonly, nonatomic) CGFloat fps;
@property (readonly, nonatomic) CGFloat sampleRate;
@property (readwrite, nonatomic) CGFloat rate;//设置解码播放速度, 0.5-2.0
@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;
@property (readonly, nonatomic) NSUInteger audioStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedAudioStream;
@property (readonly, nonatomic) NSUInteger subtitleStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedSubtitleStream;
@property (readonly, nonatomic) BOOL validVideo;
@property (readonly, nonatomic) BOOL validAudio;
@property (readonly, nonatomic) BOOL validSubtitles;
@property (readonly, nonatomic) BOOL validFilter;
@property (readonly, nonatomic, strong) NSDictionary *info;
@property (readonly, nonatomic, strong) NSString *videoStreamFormatName;
@property (readonly, nonatomic) BOOL isNetwork;
@property (readonly, nonatomic) CGFloat startTime;
@property (readwrite, nonatomic) BOOL disableDeinterlacing;
@property (readwrite, nonatomic, strong) CYPlayerDecoderInterruptCallback interruptCallback;
@property (nonatomic, readwrite, assign) CYVideoDecodeType decodeType;

+ (id) movieDecoderWithContentPath: (NSString *) path
                             error: (NSError **) perror;

- (BOOL) openFile: (NSString *) path
            error: (NSError **) perror;

-(void) closeFile;

- (BOOL) setupVideoFrameFormat: (CYVideoFrameFormat) format;

- (NSArray *) decodeFrames: (CGFloat) minDuration;

- (NSArray *) decodeTargetFrames: (CGFloat) minDuration :(CGFloat)targetPos;

- (void) concurrentDecodeFrames:(CGFloat)minDuration compeletionHandler:(CYPlayerCompeletionDecode)compeletion;

- (void) asyncDecodeFrames:(CGFloat)minDuration targetPosition:(CGFloat)targetPos compeletionHandler:(CYPlayerCompeletionDecode)compeletion;
@end

@interface CYPlayerSubtitleASSParser : NSObject

+ (NSArray *) parseEvents: (NSString *) events;
+ (NSArray *) parseDialogue: (NSString *) dialogue
                  numFields: (NSUInteger) numFields;
+ (NSString *) removeCommandsFromEventText: (NSString *) text;

@end
