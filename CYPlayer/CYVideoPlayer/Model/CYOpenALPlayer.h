//
//  CYOpenALPlayer.h
//  CYPlayer
//
//  Created by 黄威 on 2018/8/31.
//  Copyright © 2018年 Sutan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

@interface CYOpenALPlayer : NSObject
{
    ALCcontext *mContext;
    ALCdevice *mDevice;
    ALuint outSourceID;
    
    NSMutableDictionary* soundDictionary;
    NSMutableArray* bufferStorageArray;
    
    ALuint buff;
    NSTimer* updateBufferTimer;
    
    ALenum audioFormat;
    int sampleRate;
}
@property (nonatomic)ALenum audioFormat;
@property (nonatomic)ALCcontext *mContext;
@property (nonatomic)ALCdevice *mDevice;
@property (nonatomic, assign) ALuint outSourceID;
@property (nonatomic,retain)NSMutableDictionary* soundDictionary;
@property (nonatomic,retain)NSMutableArray* bufferStorageArray;

- (BOOL)isPlaying;
- (void)initOpenAL:(int)format :(int)sampleRate;
- (void)openAudioFromQueue:(unsigned char *)dataBuffer withLength: (int)length;
- (void)playSound;
- (void)playSound:(NSString*)soundKey;
//如果声音不循环,那么它将会自然停止。如果是循环的,你需要停止
- (void)stopSound;
- (void)stopSound:(NSString*)soundKey;

- (void)cleanUpOpenAL;
- (void)cleanUpOpenAL:(id)sender;
@end
