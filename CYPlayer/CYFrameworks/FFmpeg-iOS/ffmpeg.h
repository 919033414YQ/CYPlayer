//
//  Header.h
//  CYPlayer
//
//  Created by 黄威 on 2018/8/20.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AudioToolbox/AudioToolbox.h>
#include "avcodec.h"
#include "avdevice.h"
#include "avfilter.h"
#include "avformat.h"
#include "avutil.h"
#include "swscale.h"
#include "swresample.h"
#include "buffersrc.h"
#include "buffersink.h"
#include "avfiltergraph.h"
#include "eval.h"

static double FFmpegVersionNumber = 3.4;

#endif /* Header_h */
