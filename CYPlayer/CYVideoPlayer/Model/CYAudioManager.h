//
//  CYAudioManager.h
//  kxmovie
//
//  Created by Kolyvan on 23.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of CYMovie
//  CYMovie is licenced under the LGPL v3, see lgpl-3.0.txt


#import <CoreFoundation/CoreFoundation.h>

typedef void (^CYAudioManagerOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);

@protocol CYAudioManager <NSObject>

@property (readonly) UInt32             numOutputChannels;
@property (readonly) Float64            samplingRate;
@property (readonly) UInt32             numBytesPerSample;
@property (readonly) Float32            outputVolume;
@property (readonly) BOOL               playing;
@property (readonly, strong) NSString   *audioRoute;

@property (readwrite, copy) CYAudioManagerOutputBlock outputBlock;

- (BOOL) activateAudioSession;
- (void) deactivateAudioSession;
- (BOOL) play;
- (void) pause;

@end

@interface CYAudioManager : NSObject
+ (id<CYAudioManager>) audioManager;
@end
