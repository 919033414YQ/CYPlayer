//
//  CYPlayerDecoder.h
//  cyplayer
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/cyplayer
//  this file is part of CYPlayer
//  CYPlayer is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

@interface CYPlayerDecoder : NSObject

@property (readonly, nonatomic, strong) NSString *path;
@property (readonly, nonatomic) BOOL isEOF;
@property (readwrite,nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@property (readonly, nonatomic) CGFloat fps;
@property (readonly, nonatomic) CGFloat sampleRate;
@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;
@property (readonly, nonatomic) NSUInteger audioStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedAudioStream;
@property (readonly, nonatomic) NSUInteger subtitleStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedSubtitleStream;
@property (readonly, nonatomic) BOOL validVideo;
@property (readonly, nonatomic) BOOL validAudio;
@property (readonly, nonatomic) BOOL validSubtitles;
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


@end

@interface CYPlayerSubtitleASSParser : NSObject

+ (NSArray *) parseEvents: (NSString *) events;
+ (NSArray *) parseDialogue: (NSString *) dialogue
                  numFields: (NSUInteger) numFields;
+ (NSString *) removeCommandsFromEventText: (NSString *) text;

@end
