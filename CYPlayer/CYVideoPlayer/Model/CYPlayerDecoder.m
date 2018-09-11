//
//  CYPlayerDecoder.m
//  cyplayer
//
//  Created by yellowei on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/yellowei/cyplayer
//  this file is part of CYPlayer
//  CYPlayer is licenced under the LGPL v3, see lgpl-3.0.txt

#import "CYPlayerDecoder.h"
#import <Accelerate/Accelerate.h>
#import "ffmpeg.h"
#import "CYPCMAudioManager.h"
#import "CYLogger.h"
#import "CYOpenALPlayer.h"
#import "pixfmt.h"
#import <objc/runtime.h>


////////////////////////////////////////////////////////////////////////////////
NSString * cyplayerErrorDomain = @"com.yellowei.www.CYPlayer";
static void FFLog(void* context, int level, const char* format, va_list args);

static NSError * cyplayerError (NSInteger code, id info)
{
    NSDictionary *userInfo = nil;
    
    if ([info isKindOfClass: [NSDictionary class]]) {
        
        userInfo = info;
        
    } else if ([info isKindOfClass: [NSString class]]) {
        
        userInfo = @{ NSLocalizedDescriptionKey : info };
    }
    
    return [NSError errorWithDomain:cyplayerErrorDomain
                               code:code
                           userInfo:userInfo];
}

static NSString * errorMessage (cyPlayerError errorCode)
{
    switch (errorCode) {
        case cyPlayerErrorNone:
            return @"";
            
        case cyPlayerErrorOpenFile:
            return NSLocalizedString(@"Unable to open file", nil);
            
        case cyPlayerErrorStreamInfoNotFound:
            return NSLocalizedString(@"Unable to find stream information", nil);
            
        case cyPlayerErrorStreamNotFound:
            return NSLocalizedString(@"Unable to find stream", nil);
            
        case cyPlayerErrorCodecNotFound:
            return NSLocalizedString(@"Unable to find codec", nil);
            
        case cyPlayerErrorOpenCodec:
            return NSLocalizedString(@"Unable to open codec", nil);
            
        case cyPlayerErrorAllocateFrame:
            return NSLocalizedString(@"Unable to allocate frame", nil);
            
        case cyPlayerErroSetupScaler:
            return NSLocalizedString(@"Unable to setup scaler", nil);
            
        case cyPlayerErroReSampler:
            return NSLocalizedString(@"Unable to setup resampler", nil);
            
        case cyPlayerErroUnsupported:
            return NSLocalizedString(@"The ability is not supported", nil);
    }
}

////////////////////////////////////////////////////////////////////////////////

static BOOL audioCodecIsSupported(AVCodecContext *audio)
{
    if (audio->sample_fmt == AV_SAMPLE_FMT_S16) {

        CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];
        return  (int)audioManager.avaudioSessionSamplingRate == audio->sample_rate &&
                audioManager.avaudioSessionNumOutputChannels == audio->channels;
    }
    return NO;
}

#ifdef DEBUG
static void fillSignal(SInt16 *outData,  UInt32 numFrames, UInt32 numChannels)
{
    static float phase = 0.0;
    
    for (int i=0; i < numFrames; ++i)
    {
        for (int iChannel = 0; iChannel < numChannels; ++iChannel)
        {
            float theta = phase * M_PI * 2;
            outData[i*numChannels + iChannel] = sin(theta) * (float)INT16_MAX;
        }
        phase += 1.0 / (44100 / 440.0);
        if (phase > 1.0) phase = -1;
    }
}

static void fillSignalF(float *outData,  UInt32 numFrames, UInt32 numChannels)
{
    static float phase = 0.0;
    
    for (int i=0; i < numFrames; ++i)
    {
        for (int iChannel = 0; iChannel < numChannels; ++iChannel)
        {
            float theta = phase * M_PI * 2;
            outData[i*numChannels + iChannel] = sin(theta);
        }
        phase += 1.0 / (44100 / 440.0);
        if (phase > 1.0) phase = -1;
    }
}

static void testConvertYUV420pToRGB(AVFrame * frame, uint8_t *outbuf, int linesize, int height)
{
    const int linesizeY = frame->linesize[0];
    const int linesizeU = frame->linesize[1];
    const int linesizeV = frame->linesize[2];
    
    assert(height == frame->height);
    assert(linesize  <= linesizeY * 3);
    assert(linesizeY == linesizeU * 2);
    assert(linesizeY == linesizeV * 2);
    
    uint8_t *pY = frame->data[0];
    uint8_t *pU = frame->data[1];
    uint8_t *pV = frame->data[2];
    
    const int width = linesize / 3;
    
    for (int y = 0; y < height; y += 2) {
        
        uint8_t *dst1 = outbuf + y       * linesize;
        uint8_t *dst2 = outbuf + (y + 1) * linesize;
        
        uint8_t *py1  = pY  +  y       * linesizeY;
        uint8_t *py2  = py1 +            linesizeY;
        uint8_t *pu   = pU  + (y >> 1) * linesizeU;
        uint8_t *pv   = pV  + (y >> 1) * linesizeV;
        
        for (int i = 0; i < width; i += 2) {
            
            int Y1 = py1[i];
            int Y2 = py2[i];
            int Y3 = py1[i+1];
            int Y4 = py2[i+1];
            
            int U = pu[(i >> 1)] - 128;
            int V = pv[(i >> 1)] - 128;
            
            int dr = (int)(             1.402f * V);
            int dg = (int)(0.344f * U + 0.714f * V);
            int db = (int)(1.772f * U);
            
            int r1 = Y1 + dr;
            int g1 = Y1 - dg;
            int b1 = Y1 + db;
            
            int r2 = Y2 + dr;
            int g2 = Y2 - dg;
            int b2 = Y2 + db;
            
            int r3 = Y3 + dr;
            int g3 = Y3 - dg;
            int b3 = Y3 + db;
            
            int r4 = Y4 + dr;
            int g4 = Y4 - dg;
            int b4 = Y4 + db;
            
            r1 = r1 > 255 ? 255 : r1 < 0 ? 0 : r1;
            g1 = g1 > 255 ? 255 : g1 < 0 ? 0 : g1;
            b1 = b1 > 255 ? 255 : b1 < 0 ? 0 : b1;
            
            r2 = r2 > 255 ? 255 : r2 < 0 ? 0 : r2;
            g2 = g2 > 255 ? 255 : g2 < 0 ? 0 : g2;
            b2 = b2 > 255 ? 255 : b2 < 0 ? 0 : b2;
            
            r3 = r3 > 255 ? 255 : r3 < 0 ? 0 : r3;
            g3 = g3 > 255 ? 255 : g3 < 0 ? 0 : g3;
            b3 = b3 > 255 ? 255 : b3 < 0 ? 0 : b3;
            
            r4 = r4 > 255 ? 255 : r4 < 0 ? 0 : r4;
            g4 = g4 > 255 ? 255 : g4 < 0 ? 0 : g4;
            b4 = b4 > 255 ? 255 : b4 < 0 ? 0 : b4;
            
            dst1[3*i + 0] = r1;
            dst1[3*i + 1] = g1;
            dst1[3*i + 2] = b1;
            
            dst2[3*i + 0] = r2;
            dst2[3*i + 1] = g2;
            dst2[3*i + 2] = b2;
            
            dst1[3*i + 3] = r3;
            dst1[3*i + 4] = g3;
            dst1[3*i + 5] = b3;
            
            dst2[3*i + 3] = r4;
            dst2[3*i + 4] = g4;
            dst2[3*i + 5] = b4;            
        }
    }
}
#endif

static void avStreamFPSTimeBase(AVStream *st, CGFloat defaultTimeBase, CGFloat *pFPS, CGFloat *pTimeBase)
{
    CGFloat fps, timebase;
    
    AVCodecContext *codecCtx_tmp = avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(codecCtx_tmp, st->codecpar);
//    AVCodecContext *codecCtx_tmp = st->codec;
    
    if (st->time_base.den && st->time_base.num)
        timebase = av_q2d(st->time_base);
    else if(codecCtx_tmp->time_base.den && codecCtx_tmp->time_base.num)
        timebase = av_q2d(codecCtx_tmp->time_base);
    else
        timebase = defaultTimeBase;
        
    if (codecCtx_tmp->ticks_per_frame != 1) {
        LoggerStream(0, @"WARNING: st.codec.ticks_per_frame=%d", codecCtx_tmp->ticks_per_frame);
        //timebase *= codecCtx_tmp->ticks_per_frame;
    }
         
    if (st->avg_frame_rate.den && st->avg_frame_rate.num)
        fps = av_q2d(st->avg_frame_rate);
    else if (st->r_frame_rate.den && st->r_frame_rate.num)
        fps = av_q2d(st->r_frame_rate);
    else
        fps = 1.0 / timebase;
    
    if (pFPS)
        *pFPS = fps;
    if (pTimeBase)
        *pTimeBase = timebase;
    
    avcodec_free_context(&codecCtx_tmp);

}

static NSArray *collectStreams(AVFormatContext *formatCtx, enum AVMediaType codecType)
{
    NSMutableArray *ma = [NSMutableArray array];
    for (NSInteger i = 0; i < formatCtx->nb_streams; ++i)
    {
        AVStream * video_Stream      = formatCtx->streams[i];
        AVCodecContext *codecCtx = avcodec_alloc_context3(NULL);
        avcodec_parameters_to_context(codecCtx, video_Stream->codecpar);
        if (codecType == codecCtx->codec_type)
        {
            [ma addObject: [NSNumber numberWithInteger: i]];
        }
        avcodec_free_context(&codecCtx);
    }
    return [ma copy];
}

static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height)
{
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength: width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

static BOOL isNetworkPath (NSString *path)
{
    NSRange r = [path rangeOfString:@":"];
    if (r.location == NSNotFound)
        return NO;
    NSString *scheme = [path substringToIndex:r.length];
    if ([scheme isEqualToString:@"file"])
        return NO;
    return YES;
}

static int interrupt_callback(void *ctx);

////////////////////////////////////////////////////////////////////////////////

@interface CYPlayerFrame()
@property (readwrite, nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat duration;
@end

@implementation CYPlayerFrame

@end

@interface CYAudioFrame()
@property (readwrite, nonatomic, strong) NSData *samples;
@end

@implementation CYAudioFrame
- (CYPlayerFrameType) type { return CYPlayerFrameTypeAudio; }

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
    
        self.position = [aDecoder decodeDoubleForKey:@"position"];
        
        self.duration = [aDecoder decodeDoubleForKey:@"duration"];
        
        self.samples = [aDecoder decodeObjectForKey:@"samples"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.position forKey:@"position"];
    
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeObject:self.samples forKey:@"samples"];
}
@end

@interface CYVideoFrame()
@property (readwrite, nonatomic) NSUInteger width;
@property (readwrite, nonatomic) NSUInteger height;
@end

@implementation CYVideoFrame
- (CYPlayerFrameType) type { return CYPlayerFrameTypeVideo; }
@end

@interface CYVideoFrameRGB ()
@property (readwrite, nonatomic) NSUInteger linesize;
@property (readwrite, nonatomic, strong) NSData *rgb;
@end

@implementation CYVideoFrameRGB
- (CYVideoFrameFormat) format { return CYVideoFrameFormatRGB; }
- (UIImage *) asImage
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(self.width,
                                                self.height,
                                                8,
                                                24,
                                                self.linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.position = [aDecoder decodeDoubleForKey:@"position"];
        
        self.duration = [aDecoder decodeDoubleForKey:@"duration"];
        
        self.width = [aDecoder decodeIntegerForKey:@"width"];
        
        self.height = [aDecoder decodeIntegerForKey:@"height"];
        
        self.linesize = [aDecoder decodeIntegerForKey:@"linesize"];
        
        self.rgb = [aDecoder decodeObjectForKey:@"rgb"];
        
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.position forKey:@"position"];
    
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeInteger:self.width forKey:@"width"];
    
    [aCoder encodeInteger:self.height forKey:@"height"];
    
    [aCoder encodeInteger:self.linesize forKey:@"linesize"];
    
    [aCoder encodeObject:self.rgb forKey:@"rgb"];
}
@end

@interface CYVideoFrameYUV()
@property (readwrite, nonatomic, strong) NSData *luma;
@property (readwrite, nonatomic, strong) NSData *chromaB;
@property (readwrite, nonatomic, strong) NSData *chromaR;
@end

@implementation CYVideoFrameYUV
- (CYVideoFrameFormat) format { return CYVideoFrameFormatYUV; }

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.position = [aDecoder decodeDoubleForKey:@"position"];
        
        self.duration = [aDecoder decodeDoubleForKey:@"duration"];
        
        self.width = [aDecoder decodeIntegerForKey:@"width"];
        
        self.height = [aDecoder decodeIntegerForKey:@"height"];
        
        self.luma = [aDecoder decodeObjectForKey:@"luma"];
        
        self.chromaB = [aDecoder decodeObjectForKey:@"chromaB"];
        
        self.chromaR = [aDecoder decodeObjectForKey:@"chromaR"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.position forKey:@"position"];
    
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeDouble:self.width forKey:@"width"];
    
    [aCoder encodeDouble:self.height forKey:@"height"];
    
    [aCoder encodeObject:self.luma forKey:@"luma"];
    
    [aCoder encodeObject:self.chromaB forKey:@"chromaB"];
    
    [aCoder encodeObject:self.chromaR forKey:@"chromaR"];
}
@end

@interface CYArtworkFrame()
@property (readwrite, nonatomic, strong) NSData *picture;
@end

@implementation CYArtworkFrame
- (CYPlayerFrameType) type { return CYPlayerFrameTypeArtwork; }
- (UIImage *) asImage
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_picture));
    if (provider) {
        
        CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(provider,
                                                                NULL,
                                                                YES,
                                                                kCGRenderingIntentDefault);
        if (imageRef) {
            
            image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.position = [aDecoder decodeDoubleForKey:@"position"];
        
        self.duration = [aDecoder decodeDoubleForKey:@"duration"];
        
        self.picture = [aDecoder decodeObjectForKey:@"picture"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.position forKey:@"position"];
    
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeObject:self.picture forKey:@"picture"];
}
@end

@interface CYSubtitleFrame()
@property (readwrite, nonatomic, strong) NSString *text;
@end

@implementation CYSubtitleFrame
- (CYPlayerFrameType) type { return CYPlayerFrameTypeSubtitle; }

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.position = [aDecoder decodeDoubleForKey:@"position"];
        
        self.duration = [aDecoder decodeDoubleForKey:@"duration"];
        
        self.text = [aDecoder decodeObjectForKey:@"text"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.position forKey:@"position"];
    
    [aCoder encodeDouble:self.duration forKey:@"duration"];
    
    [aCoder encodeObject:self.text forKey:@"text"];
}
@end

////////////////////////////////////////////////////////////////////////////////

@interface CYPlayerDecoder () {
    
    AVDictionary        *_options;
    AVFormatContext     *_formatCtx;
	AVCodecContext      *_videoCodecCtx;
    AVCodecContext      *_audioCodecCtx;
    AVCodecContext      *_subtitleCodecCtx;
    
    //Handle Video Frames
    AVFrame             *_videoFrame;
    AVFrame             *_videoFrame1;
    AVFrame             *_videoFrame2;
    AVFrame             *_videoFrame3;
    AVFrame             *_videoFrame4;
    AVPicture           _picture;
    AVPicture           _picture1;
    AVPicture           _picture2;
    AVPicture           _picture3;
    AVPicture           _picture4;
    BOOL                _pictureValid;
    BOOL                _pictureValid1;
    BOOL                _pictureValid2;
    BOOL                _pictureValid3;
    BOOL                _pictureValid4;
    //Handle Audio Frames
    AVFrame             *_audioFrame;
    AVFrame             *_audioFrame1;
    AVFrame             *_audioFrame2;
    AVFrame             *_audioFrame3;
    AVFrame             *_audioFrame4;

    NSInteger           _videoStream;
    NSInteger           _audioStream;
    NSInteger           _subtitleStream;
	
    
    struct SwsContext   *_swsContext;
    CGFloat             _videoTimeBase;
    CGFloat             _audioTimeBase;
    CGFloat             _position;
    NSArray             *_videoStreams;
    NSArray             *_audioStreams;
    NSArray             *_subtitleStreams;
    SwrContext          *_swrContext;
    dispatch_semaphore_t _swrContextLock;
    unsigned char       *_swrBuffer;
    NSUInteger          _swrBufferSize;
    NSDictionary        *_info;
    CYVideoFrameFormat  _videoFrameFormat;
    NSUInteger          _artworkStream;
    NSInteger           _subtitleASSEvents;
    FILE                *_out_fb;
    NSInteger           _fileCount;
    int                 _dstWidth;
    int                 _dstHeight;
}
@end

@implementation CYPlayerDecoder

@dynamic duration;
@dynamic position;
@dynamic frameWidth;
@dynamic frameHeight;
@dynamic sampleRate;
@dynamic audioStreamsCount;
@dynamic subtitleStreamsCount;
@dynamic selectedAudioStream;
@dynamic selectedSubtitleStream;
@dynamic validAudio;
@dynamic validVideo;
@dynamic validSubtitles;
@dynamic info;
@dynamic videoStreamFormatName;
@dynamic startTime;

- (CGFloat) duration
{
    if (!_formatCtx)
        return 0;
    if (_formatCtx->duration == AV_NOPTS_VALUE)
        return MAXFLOAT;
    return (CGFloat)_formatCtx->duration / AV_TIME_BASE;
}

- (CGFloat) position
{
    return _position;
}

- (void) setPosition: (CGFloat)seconds
{
    _position = seconds;
    _isEOF = NO;
	   
    if ([self validVideo]) {
        int64_t ts = (int64_t)(seconds / _videoTimeBase);
//        avformat_seek_file(_formatCtx, (int)_videoStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        av_seek_frame(_formatCtx, (int)_videoStream, ts, AVSEEK_FLAG_BACKWARD);
        avcodec_flush_buffers(_videoCodecCtx);
    }
    
    if ([self validAudio]) {
        int64_t ts = (int64_t)(seconds / _audioTimeBase);
//        avformat_seek_file(_formatCtx, (int)_audioStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        av_seek_frame(_formatCtx, (int)_audioStream, ts, AVSEEK_FLAG_BACKWARD);
        avcodec_flush_buffers(_audioCodecCtx);
    }
}

- (NSUInteger) frameWidth
{
    if (_dstWidth > 0) {
        return _dstWidth;
    }
    NSUInteger width = _videoCodecCtx->width;
    NSUInteger height = _videoCodecCtx->height;
    get_video_scale_max_size(_videoCodecCtx, &width, &height);
    return width ? width : 0;
}

- (NSUInteger) frameHeight
{
    if (_dstHeight > 0)
    {
        return _dstHeight;
    }
    NSUInteger width = _videoCodecCtx->width;
    NSUInteger height = _videoCodecCtx->height;
    get_video_scale_max_size(_videoCodecCtx, &width, &height);
    return height ? height : 0;
}

- (CGFloat) sampleRate
{
    return _audioCodecCtx ? _audioCodecCtx->sample_rate : 0;
}

- (NSUInteger) audioStreamsCount
{
    return [_audioStreams count];
}

- (NSUInteger) subtitleStreamsCount
{
    return [_subtitleStreams count];
}

- (NSInteger) selectedAudioStream
{
    if (_audioStream == -1)
        return -1;
    NSNumber *n = [NSNumber numberWithInteger:_audioStream];
    return [_audioStreams indexOfObject:n];        
}

- (void) setSelectedAudioStream:(NSInteger)selectedAudioStream
{
    NSInteger audioStream = [_audioStreams[selectedAudioStream] integerValue];
    [self closeAudioStream];
    cyPlayerError errCode = [self openAudioStream: audioStream];
    if (cyPlayerErrorNone != errCode) {
        LoggerAudio(0, @"%@", errorMessage(errCode));
    }
}

- (NSInteger) selectedSubtitleStream
{
    if (_subtitleStream == -1)
        return -1;
    return [_subtitleStreams indexOfObject:@(_subtitleStream)];
}

- (void) setSelectedSubtitleStream:(NSInteger)selected
{
    [self closeSubtitleStream];
    
    if (selected == -1) {
        
        _subtitleStream = -1;
        
    } else {
        
        NSInteger subtitleStream = [_subtitleStreams[selected] integerValue];
        cyPlayerError errCode = [self openSubtitleStream:subtitleStream];
        if (cyPlayerErrorNone != errCode) {
            LoggerStream(0, @"%@", errorMessage(errCode));
        }
    }
}

- (BOOL) validAudio
{
    return (_audioStream != -1) && (self.decodeType & CYVideoDecodeTypeAudio);
}

- (BOOL) validVideo
{
    return (_videoStream != -1) && (self.decodeType & CYVideoDecodeTypeVideo);
}

- (BOOL) validSubtitles
{
    return _subtitleStream != -1;
}

- (NSDictionary *) info
{
    if (!_info) {
        
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        
        if (_formatCtx) {
        
            const char *formatName = _formatCtx->iformat->name;
            [md setValue: [NSString stringWithCString:formatName encoding:NSUTF8StringEncoding]
                  forKey: @"format"];
            
            if (_formatCtx->bit_rate) {
                
                [md setValue: [NSNumber numberWithInt:(int)(_formatCtx->bit_rate)]
                      forKey: @"bitrate"];
            }
            
            if (_formatCtx->metadata) {
                
                NSMutableDictionary *md1 = [NSMutableDictionary dictionary];
                
                AVDictionaryEntry *tag = NULL;
                 while((tag = av_dict_get(_formatCtx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX))) {
                     
                     [md1 setValue: [NSString stringWithCString:tag->value encoding:NSUTF8StringEncoding]
                            forKey: [NSString stringWithCString:tag->key encoding:NSUTF8StringEncoding]];
                 }
                
                [md setValue: [md1 copy] forKey: @"metadata"];
            }
        
            char buf[256];
            
            if (_videoStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in _videoStreams) {
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    AVCodecContext *codecCtx_tmp = avcodec_alloc_context3(NULL);
                    avcodec_parameters_to_context(codecCtx_tmp, st->codecpar);
                    avcodec_string(buf, sizeof(buf), codecCtx_tmp, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Video: "])
                        s = [s substringFromIndex:@"Video: ".length];
                    s = [s stringByAppendingString:[NSString stringWithFormat:@", %.0f FPS", _fps]];
                    [ma addObject:s];
                    avcodec_free_context(&codecCtx_tmp);
                }
                md[@"video"] = ma.copy;
            }
            
            if (_audioStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in _audioStreams) {
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s ", lang->value];
                    }
                    
                    AVCodecContext *codecCtx_tmp = avcodec_alloc_context3(NULL);
                    avcodec_parameters_to_context(codecCtx_tmp, st->codecpar);
                    avcodec_string(buf, sizeof(buf), codecCtx_tmp, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Audio: "])
                        s = [s substringFromIndex:@"Audio: ".length];
                    [ms appendString:s];
                    
                    [ma addObject:ms.copy];
                    avcodec_free_context(&codecCtx_tmp);
                }                
                md[@"audio"] = ma.copy;
            }
            
            if (_subtitleStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in _subtitleStreams) {
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s ", lang->value];
                    }
                    
                    AVCodecContext *codecCtx_tmp = avcodec_alloc_context3(NULL);
                    avcodec_parameters_to_context(codecCtx_tmp, st->codecpar);
                    avcodec_string(buf, sizeof(buf), codecCtx_tmp, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Subtitle: "])
                        s = [s substringFromIndex:@"Subtitle: ".length];
                    [ms appendString:s];
                    
                    [ma addObject:ms.copy];
                    avcodec_free_context(&codecCtx_tmp);
                }               
                md[@"subtitles"] = ma.copy;
            }
            
        }
                
        _info = [md copy];
    }
    
    return _info;
}

- (NSString *) videoStreamFormatName
{
    if (!_videoCodecCtx)
        return nil;
    
    if (_videoCodecCtx->pix_fmt == AV_PIX_FMT_NONE)
        return @"";
    
    const char *name = av_get_sample_fmt_name(_videoCodecCtx->sample_fmt);
    return name ? [NSString stringWithCString:name encoding:NSUTF8StringEncoding] : @"?";
}

- (CGFloat) startTime
{
    if ([self validVideo]) {
        
        AVStream *st = _formatCtx->streams[_videoStream];
        if (AV_NOPTS_VALUE != st->start_time)
            return st->start_time * _videoTimeBase;
        return 0;
    }
    
    if ([self validAudio]) {
        
        AVStream *st = _formatCtx->streams[_audioStream];
        if (AV_NOPTS_VALUE != st->start_time)
            return st->start_time * _audioTimeBase;
        return 0;
    }
        
    return 0;
}

+ (void)initialize
{
//    av_log_set_callback(FFLog);
    av_register_all();
    avformat_network_init();
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return self;
}

+ (id) movieDecoderWithContentPath: (NSString *) path
                             error: (NSError **) perror
{
    CYPlayerDecoder *mp = [[CYPlayerDecoder alloc] init];
    if (mp) {
        [mp openFile:path error:perror];
    }
    return mp;
}

- (void) dealloc
{
    LoggerStream(2, @"%@ dealloc", self);
    [self closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (BOOL) openFile: (NSString *) path
            error: (NSError **) perror
{
    NSAssert(path, @"nil path");
    NSAssert(!_formatCtx, @"already open");
    
    _isNetwork = isNetworkPath(path);
    
    static BOOL needNetworkInit = YES;
    if (needNetworkInit && _isNetwork) {
        
        needNetworkInit = NO;
        avformat_network_init();
    }
    
    path = path.length > 0 ? path : @"";
    _path = path;
    
    cyPlayerError errCode = [self openInput: path];
    
    if (errCode == cyPlayerErrorNone) {
        
        cyPlayerError videoErr = cyPlayerErrorOpenCodec;
        cyPlayerError audioErr = cyPlayerErrorOpenCodec;
        
        videoErr = [self openVideoStream];
        
        audioErr = [self openAudioStream];
        
        _subtitleStream = -1;
        
        if (videoErr != cyPlayerErrorNone &&
            audioErr != cyPlayerErrorNone) {
         
            errCode = videoErr; // both fails
            
        } else {
            
            _subtitleStreams = collectStreams(_formatCtx, AVMEDIA_TYPE_SUBTITLE);
        }
    }
    
    if (errCode != cyPlayerErrorNone) {
        
        [self closeFile];
        NSString *errMsg = errorMessage(errCode);
        LoggerStream(0, @"%@, %@", errMsg, path.lastPathComponent);
        if (perror)
            *perror = cyplayerError(errCode, errMsg);
        return NO;
    }
        
    return YES;
}

- (cyPlayerError) openInput: (NSString *) path
{
    AVFormatContext *formatCtx = NULL;

    if (_interruptCallback) {
        
        formatCtx = avformat_alloc_context();
        if (!formatCtx)
            return cyPlayerErrorOpenFile;
        
        __weak typeof(&*self)weakSelf = self;
        AVIOInterruptCB cb = {
            interrupt_callback,
            (__bridge void *)(weakSelf)
        };
        formatCtx->interrupt_callback = cb;
    }
    else
    {
        formatCtx = avformat_alloc_context();
        if (!formatCtx)
            return cyPlayerErrorOpenFile;
    }
    
    av_dict_set(&_options, "rtsp_transport", "tcp", 0);//设置tcp or udp，默认一般优先tcp再尝试udp
    av_dict_set(&_options, "timeout", "3000000", 0);//设置超时3秒
    av_dict_set(&_options, "re", "25", 0);
    av_dict_set(&_options, "r", "25", 0);
//    av_dict_set_int(&_options, "video_track_timescale", 25, 0);
//    av_dict_set_int(&_options, "fpsprobesize", 25, 0);
//    av_dict_set_int(&_options, "skip-calc-frame-rate", 25, 0);
    
    if ([path hasPrefix:@"rtsp"] || [path hasPrefix:@"rtmp"]) {
        // There is total different meaning for 'timeout' option in rtmp
        av_dict_set(&_options, "timeout", NULL, 0);
    }
    if (avformat_open_input(&formatCtx, [path cStringUsingEncoding: NSUTF8StringEncoding], NULL, &_options) < 0) {
        
        if (formatCtx)
            avformat_free_context(formatCtx);
        return cyPlayerErrorOpenFile;
    }
    
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        
        avformat_close_input(&formatCtx);
        return cyPlayerErrorStreamInfoNotFound;
    }

#if DEBUG
    // 打印视频流的详细信息
   av_dump_format(formatCtx, 0, [path.lastPathComponent cStringUsingEncoding: NSUTF8StringEncoding], false);
#endif
    
    
    _formatCtx = formatCtx;
    return cyPlayerErrorNone;
}

- (cyPlayerError) openVideoStream
{
    cyPlayerError errCode = cyPlayerErrorStreamNotFound;
    _videoStream = -1;
    _artworkStream = -1;
    if (!(self.decodeType & CYVideoDecodeTypeVideo))
    {
        return cyPlayerErrorStreamNotFound;
    }
    _videoStreams = collectStreams(_formatCtx, AVMEDIA_TYPE_VIDEO);
    for (NSNumber *n in _videoStreams) {
        
        const NSUInteger iStream = n.integerValue;

        if (0 == (_formatCtx->streams[iStream]->disposition & AV_DISPOSITION_ATTACHED_PIC)) {
        
            errCode = [self openVideoStream: iStream];
            if (errCode == cyPlayerErrorNone)
                break;
            
        } else {
            
            _artworkStream = iStream;
        }
    }
    
    return errCode;
}

- (cyPlayerError) openVideoStream: (NSInteger) videoStream
{    
    // get a pointer to the codec context for the video stream
    
    //    AVCodecContext *codecCtx = _formatCtx->streams[videoStream]->codec;
    AVStream * video_Stream      = _formatCtx->streams[videoStream];
    AVCodecContext *codecCtx = avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(codecCtx, video_Stream->codecpar);

    
    // find the decoder for the video stream
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if (!codec)
        return cyPlayerErrorCodecNotFound;
    
    // inform the codec that we can handle truncated bitstreams -- i.e.,
    // bitstreams where frame boundaries can fall in the middle of packets
    //if(codec->capabilities & CODEC_CAP_TRUNCATED)
    //    _codecCtx->flags |= CODEC_FLAG_TRUNCATED;
    
    // open codec
    if (avcodec_open2(codecCtx, codec, NULL) < 0)
        return cyPlayerErrorOpenCodec;
        
    _videoFrame = av_frame_alloc();
    _videoFrame1 = av_frame_alloc();
    _videoFrame2 = av_frame_alloc();
    _videoFrame3 = av_frame_alloc();
    _videoFrame4 = av_frame_alloc();

    if (!_videoFrame || !_videoFrame1 || !_videoFrame2 || !_videoFrame3 || !_videoFrame4) {
        avcodec_free_context(&codecCtx);
        return cyPlayerErrorAllocateFrame;
    }
    
    _videoStream = videoStream;
    _videoCodecCtx = codecCtx;
    
    // determine fps
    
    AVStream *st = _formatCtx->streams[_videoStream];
    avStreamFPSTimeBase(st, 0.04, &_fps, &_videoTimeBase);
    
    LoggerVideo(1, @"video codec size: %d:%d fps: %.3f tb: %f",
                (int)(self.frameWidth),
                (int)(self.frameHeight),
                _fps,
                _videoTimeBase);
    
    LoggerVideo(1, @"video start time %f", st->start_time * _videoTimeBase);
    LoggerVideo(1, @"video disposition %d", st->disposition);
    
    st = NULL;
    return cyPlayerErrorNone;
}

- (cyPlayerError) openAudioStream
{
    cyPlayerError errCode = cyPlayerErrorStreamNotFound;
    _audioStream = -1;
    if (!(self.decodeType & CYVideoDecodeTypeAudio))
    {
        return cyPlayerErrorStreamNotFound;
    }
    _audioStreams = collectStreams(_formatCtx, AVMEDIA_TYPE_AUDIO);
    for (NSNumber *n in _audioStreams) {
    
        errCode = [self openAudioStream: n.integerValue];
        if (errCode == cyPlayerErrorNone)
            break;
    }    
    return errCode;
}

- (cyPlayerError) openAudioStream: (NSInteger) audioStream
{
    _swrContextLock = dispatch_semaphore_create(1);//初始化锁
    AVCodecContext *codecCtx = avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(codecCtx, _formatCtx->streams[audioStream]->codecpar);
    SwrContext *swrContext = NULL;
                   
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if(!codec)
        return cyPlayerErrorCodecNotFound;
        
    if (avcodec_open2(codecCtx, codec, NULL) < 0)
         return cyPlayerErrorOpenCodec;
    
    if (!audioCodecIsSupported(codecCtx)) {

        CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];

        audioManager.avcodecContextNumOutputChannels = audioManager.avaudioSessionNumOutputChannels;
        if (codecCtx->sample_rate < CYPCMAudioManagerNormalSampleRate)
        {
            audioManager.avcodecContextSamplingRate = codecCtx->sample_rate;
        }
        else
        {
            audioManager.avcodecContextSamplingRate = CYPCMAudioManagerNormalSampleRate;
        }

        dispatch_semaphore_wait(_swrContextLock, DISPATCH_TIME_FOREVER);
        BOOL result = audio_swr_resampling_audio_init(&swrContext, codecCtx) <= 0;
        dispatch_semaphore_signal(_swrContextLock);
        if (result)
        {
            return cyPlayerErroReSampler;
        }
    }
    _audioFrame = av_frame_alloc();
    _audioFrame1 = av_frame_alloc();
    _audioFrame2 = av_frame_alloc();
    _audioFrame3 = av_frame_alloc();
    _audioFrame4 = av_frame_alloc();

    if (!_audioFrame || !_audioFrame1 || !_audioFrame2 || !_audioFrame3 || !_audioFrame4) {
        if (swrContext)
        {
            swr_free(&swrContext);
        }
        avcodec_free_context(&codecCtx);
        return cyPlayerErrorAllocateFrame;
    }
    
    _audioStream = audioStream;
    _audioCodecCtx = codecCtx;
    _swrContext = swrContext;
    
    AVStream *st = _formatCtx->streams[_audioStream];

//    int64_t out_sample_rate;
//    if (_swrContext)
//    {
//        av_opt_get_int(_swrContext, "out_sample_rate", 0, &out_sample_rate);
//        _audioTimeBase = 1.0 / out_sample_rate;
//    }
//    else
    {
        avStreamFPSTimeBase(st, 0.025, 0, &_audioTimeBase);
    }
    
    
    
    LoggerAudio(1, @"audio codec smr: %.d fmt: %d chn: %d tb: %f %@",
                _audioCodecCtx->sample_rate,
                _audioCodecCtx->sample_fmt,
                _audioCodecCtx->channels,
                _audioTimeBase,
                _swrContext ? @"resample" : @"");
    
    st = NULL;
    return cyPlayerErrorNone; 
}

- (cyPlayerError) openSubtitleStream: (NSInteger) subtitleStream
{
    AVCodecContext *codecCtx = avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(codecCtx, _formatCtx->streams[subtitleStream]->codecpar);
    
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if(!codec)
    {
        avcodec_free_context(&codecCtx);
        return cyPlayerErrorCodecNotFound;
    }
    
    const AVCodecDescriptor *codecDesc = avcodec_descriptor_get(codecCtx->codec_id);
    if (codecDesc && (codecDesc->props & AV_CODEC_PROP_BITMAP_SUB)) {
        // Only text based subtitles supported
        avcodec_free_context(&codecCtx);
        return cyPlayerErroUnsupported;
    }
    
    if (avcodec_open2(codecCtx, codec, NULL) < 0)
    {
        avcodec_free_context(&codecCtx);
        return cyPlayerErrorOpenCodec;
    }
    
    _subtitleStream = subtitleStream;
    _subtitleCodecCtx = codecCtx;
    
    LoggerStream(1, @"subtitle codec: '%s' mode: %d enc: %s",
                codecDesc->name,
                codecCtx->sub_charenc_mode,
                codecCtx->sub_charenc);
    
    _subtitleASSEvents = -1;
    
    if (codecCtx->subtitle_header_size) {
                
        NSString *s = [[NSString alloc] initWithBytes:codecCtx->subtitle_header
                                               length:codecCtx->subtitle_header_size
                                             encoding:NSASCIIStringEncoding];
        
        if (s.length) {
            
            NSArray *fields = [CYPlayerSubtitleASSParser parseEvents:s];
            if (fields.count && [fields.lastObject isEqualToString:@"Text"]) {
                _subtitleASSEvents = fields.count;
                LoggerStream(2, @"subtitle ass events: %@", [fields componentsJoinedByString:@","]);
            }
        }
    }
    
    return cyPlayerErrorNone;
}

-(void) closeFile
{
    [self closeAudioStream];
    [self closeVideoStream];
    [self closeSubtitleStream];
    
    _videoStreams = nil;
    _audioStreams = nil;
    _subtitleStreams = nil;
    
    if (_formatCtx) {
        
        _formatCtx->interrupt_callback.opaque = NULL;
        _formatCtx->interrupt_callback.callback = NULL;
        
        avformat_close_input(&_formatCtx);
        _formatCtx = NULL;
    }
    
    if (_options)
    {
        av_dict_free(&_options);
    }
    
    _interruptCallback = nil;
    _isEOF = NO;
}

- (void) closeVideoStream
{
    _videoStream = -1;
    
    [self closeScaler];
    
    if (_videoFrame) {
        av_free(_videoFrame);
        _videoFrame = NULL;
    }
    if (_videoFrame1) {
        av_free(_videoFrame1);
        _videoFrame1 = NULL;
    }
    if (_videoFrame2) {
        av_free(_videoFrame2);
        _videoFrame2 = NULL;
    }
    if (_videoFrame3) {
        av_free(_videoFrame3);
        _videoFrame3 = NULL;
    }
    if (_videoFrame4) {
        av_free(_videoFrame4);
        _videoFrame4 = NULL;
    }
    
    if (_videoCodecCtx) {
        avcodec_free_context(&_videoCodecCtx);
        _videoCodecCtx = NULL;
    }
}

- (void) closeAudioStream
{
    _audioStream = -1;
        
    if (_swrBuffer) {
        
        free(_swrBuffer);
        _swrBuffer = NULL;
        _swrBufferSize = 0;
    }
    
    if (_swrContext) {
        
        swr_free(&_swrContext);
        _swrContext = NULL;
    }
        
    if (_audioFrame) {
        av_free(_audioFrame);
        _audioFrame = NULL;
    }
    if (_audioFrame1) {
        av_free(_audioFrame1);
        _audioFrame1 = NULL;
    }
    if (_audioFrame2) {
        av_free(_audioFrame2);
        _audioFrame2 = NULL;
    }
    if (_audioFrame3) {
        av_free(_audioFrame3);
        _audioFrame3 = NULL;
    }
    if (_audioFrame4) {
        av_free(_audioFrame4);
        _audioFrame4 = NULL;
    }
    
    if (_audioCodecCtx) {
        avcodec_free_context(&_audioCodecCtx);
        _audioCodecCtx = NULL;
    }
}

- (void) closeSubtitleStream
{
    _subtitleStream = -1;
    
    if (_subtitleCodecCtx) {
        
        avcodec_free_context(&_subtitleCodecCtx);
        _subtitleCodecCtx = NULL;
    }
}

- (void) closeScaler
{
    if (_swsContext) {
        sws_freeContext(_swsContext);
        _swsContext = NULL;
    }
    
    if (_pictureValid) {
        avpicture_free(&_picture);
        _pictureValid = NO;
    }
    if (_pictureValid1) {
        avpicture_free(&_picture1);
        _pictureValid1 = NO;
    }
    if (_pictureValid2) {
        avpicture_free(&_picture2);
        _pictureValid2 = NO;
    }
    if (_pictureValid3) {
        avpicture_free(&_picture3);
        _pictureValid3 = NO;
    }
    if (_pictureValid4) {
        avpicture_free(&_picture4);
        _pictureValid4 = NO;
    }
}

- (BOOL) setupScalerWithPicture:(AVPicture *)picture isValid:(BOOL *)isValid Width:(int)width Heigth:(int)height DstFormat:(int)format
{
    [self closeScaler];
    
    *isValid = avpicture_alloc(picture,
                                    format,
                                    width,
                                    height) == 0;
    
	if (!(*isValid))
        return NO;

	_swsContext = sws_getCachedContext(_swsContext,
                                       _videoCodecCtx->width,
                                       _videoCodecCtx->height,
                                       _videoCodecCtx->pix_fmt,
                                       width,
                                       height,
                                       format,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
        
    return _swsContext != NULL;
}


/**
 获取视频方向, 1为横向, 2为纵向, 3为正方形

 @param videoCodecCtx videoCodecCtx
 @return  1为横向, 2为纵向, 3为正方形
 */
int video_direction(AVCodecContext *videoCodecCtx)
{
    CGFloat width = videoCodecCtx->width;
    CGFloat height = videoCodecCtx->height;
    
    if (width > height) {
        return 1;
    }else if (height > width) {
        return 2;
    }else if (width == height) {
        return 3;
    }else {
        return 0;
    }
}

void get_video_scale_max_size(AVCodecContext *videoCodecCtx, int * width, int * height)
{
    
    CGFloat scr_width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scr_height = [UIScreen mainScreen].bounds.size.height;
    
    *width = videoCodecCtx->width;
    *height = videoCodecCtx->height;

    CGFloat ori_scale = round( ((CGFloat)(*width) / (CGFloat)(*height)) * 1000.0 ) / 1000.0;
    switch (video_direction(videoCodecCtx))
    {
        case 1://横向
        {
            if (*width > scr_height) {
                CGFloat scr_scale = round( (scr_height / scr_width) * 1000.0 ) / 1000.0;
                if (scr_scale < ori_scale)
                {
                    *width = scr_height;
                    *height = round(scr_height / ori_scale);
                }
                else if (scr_scale > ori_scale)
                {
                    *height = scr_width;
                    *width = round(scr_width * ori_scale);
                }
                else
                {
                    *width = scr_height;
                    *height = scr_width;
                }
            }
        }
            break;
        case 2://纵向
        {
            if (*width > scr_width) {
                CGFloat scr_scale = round( (scr_width / scr_height) * 1000.0 ) / 1000.0;
                
                if (scr_scale > ori_scale)
                {
                    *height = scr_height;
                    *width = round(scr_height * ori_scale);
                }
                else if (scr_scale < ori_scale)
                {
                    *width = scr_width;
                    *height = round(scr_width / ori_scale);
                }
                else
                {
                    *width = scr_width;
                    *height = scr_height;
                }
            }
        }
            break;
        case 3:
        {
            if (*width > scr_width) {
                *width = scr_width;
                *height = scr_width;
            }
        }
            break;
            
        default:
            break;
    }
}

- (CYVideoFrame *) handleVideoFrame:(AVFrame *)videoFrame Picture:(AVPicture *)picture isPictureValid:(BOOL *)isPictureValid
{
    if (!videoFrame->data[0])
        return nil;
 
    CYVideoFrame *frame;
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    
    CGFloat position = av_frame_get_best_effort_timestamp(videoFrame) * _videoTimeBase;
    CGFloat duration = 0.0;
    
    const int64_t frameDuration = av_frame_get_pkt_duration(videoFrame);
    if (frameDuration) {
        
        duration = frameDuration * _videoTimeBase;
        duration += videoFrame->repeat_pict * _videoTimeBase * 0.5;
        
    } else {
        // sometimes, ffmpeg unable to determine a frame duration
        // as example yuvj420p stream from web camera
        duration = 1.0 / _fps;
    }
    
    //判断是否丢弃帧
    if ( _fps >= CYPlayerDecoderMaxFPS)
    {
        CGFloat fps_scale =  _fps / CYPlayerDecoderMaxFPS;

        duration *= fps_scale;

    }
    
    if ((_position > position) &&
        _position != 0)
    {
        switch (_videoFrameFormat) {
            case CYVideoFrameFormatYUV:
            {
                frame = [[CYVideoFrameYUV alloc] init];
                frame.position = position;
                frame.duration = duration;
                CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSLog(@"Linked handleVideoFrame in %f ms", linkTime *1000.0);
            }
                return nil;

            default:
            {
                frame = [[CYVideoFrameRGB alloc] init];
                frame.position = position;
                frame.duration = duration;
                CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSLog(@"Linked handleVideoFrame in %f ms", linkTime *1000.0);
            }
                return nil;;
        }
    }

    
    
    int width = _videoCodecCtx->width;
    int height = _videoCodecCtx->height;
    if (!(_dstWidth > 0 && _dstHeight > 0))
    {
        get_video_scale_max_size(_videoCodecCtx, &width, &height);
        _dstWidth = width;
        _dstHeight = height;
    }
    else
    {
        width = _dstWidth;
        height = _dstHeight;
    }
    
    if (_videoFrameFormat == CYVideoFrameFormatYUV) {
        
        if (_videoCodecCtx->width != width)//宽高发生了改变
        {
            if (!_swsContext &&
                ![self setupScalerWithPicture:picture isValid:isPictureValid Width:width Heigth:height DstFormat:_videoCodecCtx->pix_fmt]) {
                
                LoggerVideo(0, @"fail setup video scaler");
                return nil;
            }
//            const int lineSize[8]  = { width, width / 2, width / 2, 0, 0, 0, 0, 0 };
           
            
            //在这写入要计算时间的代码
            sws_scale(_swsContext,
                      (const uint8_t **)videoFrame->data,
                      videoFrame->linesize,
                      0,
                      videoFrame->height,
                      (*picture).data,
                      (*picture).linesize);

            
            CYVideoFrameYUV * yuvFrame = [[CYVideoFrameYUV alloc] init];
            
            yuvFrame.luma = copyFrameData((*picture).data[0],
                                          (*picture).linesize[0],
                                          width,
                                          height);
            
            yuvFrame.chromaB = copyFrameData((*picture).data[1],
                                             (*picture).linesize[1],
                                             width / 2,
                                             height / 2);
            
            yuvFrame.chromaR = copyFrameData((*picture).data[2],
                                             (*picture).linesize[2],
                                             width / 2,
                                             height / 2);
            
            frame = yuvFrame;
            
           

        }
        else
        {
            CYVideoFrameYUV * yuvFrame = [[CYVideoFrameYUV alloc] init];
            
            yuvFrame.luma = copyFrameData(videoFrame->data[0],
                                          videoFrame->linesize[0],
                                          width,
                                          height);
            
            yuvFrame.chromaB = copyFrameData(videoFrame->data[1],
                                             videoFrame->linesize[1],
                                             width / 2,
                                             height / 2);
            
            yuvFrame.chromaR = copyFrameData(videoFrame->data[2],
                                             videoFrame->linesize[2],
                                             width / 2,
                                             height / 2);
            
            frame = yuvFrame;
        }
       

    } else {
        
        if (!_swsContext &&
            ![self setupScalerWithPicture:picture isValid:isPictureValid Width:width Heigth:height DstFormat:AV_PIX_FMT_RGB24]) {
            
            LoggerVideo(0, @"fail setup video scaler");
            return nil;
        }
        
        sws_scale(_swsContext,
                  (const uint8_t **)videoFrame->data,
                  videoFrame->linesize,
                  0,
                  _videoCodecCtx->height,
                  (*picture).data,
                  (*picture).linesize);
        
        
        CYVideoFrameRGB *rgbFrame = [[CYVideoFrameRGB alloc] init];
        
        rgbFrame.linesize = (*picture).linesize[0];
        rgbFrame.rgb = [NSData dataWithBytes:(*picture).data[0]
                                    length:rgbFrame.linesize * height];
        frame = rgbFrame;
    }    

    frame.width = width;
    frame.height = height;
    frame.position = position;
    frame.duration = duration;
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"Linked handleVideoFrame in %f ms", linkTime *1000.0);
#if 0
    LoggerVideo(2, @"VFD: %.4f %.4f | %lld ",
                frame.position,
                frame.duration,
                av_frame_get_pkt_pos(videoFrame));

    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"Linked in %f ms", linkTime *1000.0);
#endif
    return frame;
}


/**
 初始化转换参数

 @param swr_ctx SwrContext 转换参数
 @param codec AVCodecContext
 */
int audio_swr_resampling_audio_init(SwrContext **swr_ctx, AVCodecContext *codec)
{
//    if(codec->sample_fmt == AV_SAMPLE_FMT_S16 || codec->sample_fmt == AV_SAMPLE_FMT_S32 ||codec->sample_fmt == AV_SAMPLE_FMT_U8){
//
//        LoggerAudio(1, @"codec->sample_fmt:%d", codec->sample_fmt);
//
//        if(*swr_ctx){
//
//            swr_free(swr_ctx);
//
//            *swr_ctx = NULL;
//        }
//        return 2;
//    }
    
    if(*swr_ctx){
        swr_free(swr_ctx);
    }
    
    *swr_ctx = swr_alloc();
    
    if(!*swr_ctx){
        
        LoggerAudio(1, @"%@",@"swr_alloc failed");
        
        return -1;
        
    }
    
    
    CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];
    /* set options */

    if (codec->channel_layout)
    {
        av_opt_set_int(*swr_ctx, "in_channel_layout",    codec->channel_layout, 0);
    }
    else
    {
        av_opt_set_int(*swr_ctx, "in_channel_layout",    av_get_default_channel_layout(codec->channels), 0);
    }
    
    av_opt_set_int(*swr_ctx, "in_sample_rate",       codec->sample_rate, 0);
    
    av_opt_set_sample_fmt(*swr_ctx, "in_sample_fmt", codec->sample_fmt, 0);
    
    av_opt_set_int(*swr_ctx, "out_channel_layout",    av_get_default_channel_layout((int)(audioManager.avcodecContextNumOutputChannels)), 0);
    
    av_opt_set_int(*swr_ctx, "out_sample_rate",       audioManager.avcodecContextSamplingRate, 0);
    
    av_opt_set_sample_fmt(*swr_ctx, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);// AV_SAMPLE_FMT_S16
    
    /* initialize the resampling context */
    
    int ret = 0;
    
    if ((ret = swr_init(*swr_ctx)) < 0) {
        
        LoggerAudio(1, @"Failed to initialize the resampling context\n");
        
        if(*swr_ctx){
            
            swr_free(swr_ctx);
            
            *swr_ctx = NULL;
            
        }
        
        return ret;
        
    }
    
    return 1;
    
}


int audio_swr_resampling_audio(SwrContext *swr_ctx, AVFrame *audioFrame, uint8_t **targetData){
    
    int len = swr_convert(swr_ctx,
                          targetData,
                          audioFrame->nb_samples,
                          (const uint8_t **)audioFrame->extended_data,
                          audioFrame->nb_samples);
    
    if(len < 0){
        
        LoggerAudio(0, @"error swr_convert");
        
        return -1;
        
    }
    
    CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];
    
    long int dst_bufsize = len * audioManager.avcodecContextNumOutputChannels * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16);
    
//    LoggerAudio(1, @" dst_bufsize:%d", (int)dst_bufsize);
    
    return (int)dst_bufsize;
}

void audio_swr_resampling_audio_destory(SwrContext **swr_ctx){
    
    if(*swr_ctx){
        
        swr_free(swr_ctx);
        
        *swr_ctx = NULL;
    }
}

- (CYAudioFrame *) handleAudioFrame:(AVFrame *)audioFrame
{
    if (!audioFrame->data[0])
        return nil;
 
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    
    CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];
    const NSUInteger numChannels = audioManager.avcodecContextNumOutputChannels;
    CGFloat position = av_frame_get_best_effort_timestamp(audioFrame) * _audioTimeBase;
    CGFloat duration = av_frame_get_pkt_duration(audioFrame) * _audioTimeBase;;
    
    NSInteger numFrames;
    
    void * audioData;
    int out_linesize;
    
    const int bufSize = av_samples_get_buffer_size(&out_linesize,
                                                   (int)audioManager.avcodecContextNumOutputChannels,
                                                   audioFrame->nb_samples,
                                                   AV_SAMPLE_FMT_S16,
                                                   1);

    dispatch_semaphore_wait(_swrContextLock, DISPATCH_TIME_FOREVER);
    if (_swrContext) {
        
        const NSUInteger ratio = MAX(1, audioManager.avcodecContextSamplingRate / _audioCodecCtx->sample_rate) *
        MAX(1, audioManager.avcodecContextNumOutputChannels / _audioCodecCtx->channels) * 2;
    
        if (!_swrBuffer || _swrBufferSize < bufSize) {
            _swrBufferSize = bufSize;
            _swrBuffer = realloc(_swrBuffer, _swrBufferSize);
        }
        
        
        
        Byte *outbuf[2] = { _swrBuffer, 0 };
        
        numFrames = audio_swr_resampling_audio(_swrContext, audioFrame, outbuf);
        
//        //存储PCM数据，注意：m_SwrCtx即使进行了转换，也要判断转换后的数据是否分平面
//        if (_swrContext ) {
//            NSString *filename=[[self infoFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.pcm", _fileCount]];
//            const char *out_file = [filename cStringUsingEncoding:NSUTF8StringEncoding];
//            if (!_out_fb)
//            {
//                _out_fb = fopen(out_file, "wb");
//            }
//            size_t size = fwrite(outbuf[0], 1, bufSize, _out_fb);
//            fclose(_out_fb);
//            //            _fileCount++;
//        }
        
        if (numFrames < 0) {
            LoggerAudio(0, @"fail resample audio");
            return nil;
        }
        audioData = _swrBuffer;
        
    } else {
    
        if (_audioCodecCtx->sample_fmt != AV_SAMPLE_FMT_S16) {
            NSAssert(false, @"bucheck, audio format is invalid");
            return nil;
        }
        
        audioData = audioFrame->extended_data;
        numFrames = out_linesize;
    }
    dispatch_semaphore_signal(_swrContextLock);
    
    const NSUInteger numElements = numFrames * numChannels;
    
//    NSMutableData *data = [NSMutableData dataWithLength:numElements * sizeof(float)];
//
//    float scale = 1.0 / (float)INT16_MAX ;
//    vDSP_vflt16((SInt16 *)audioData, 1, data.mutableBytes, 1, numElements);
//    vDSP_vsmul(data.mutableBytes, 1, &scale, data.mutableBytes, 1, numElements);
    
    CYAudioFrame *frame = [[CYAudioFrame alloc] init];
//    frame.samples = data;
    frame.samples = [NSData dataWithBytes:audioData length:numFrames];
    if (duration == 0) {
        // sometimes ffmpeg can't determine the duration of audio frame
        // especially of wma/wmv format
        // so in this case must compute duration
        duration = frame.samples.length / (sizeof(float) * numChannels * audioManager.avcodecContextSamplingRate);
    }
    frame.position = position;
    frame.duration = duration;
    
#if 0
    LoggerAudio(2, @"AFD: %.4f %.4f | %.4f ",
                frame.position,
                frame.duration,
                frame.samples.length / (8.0 * 44100.0));
#endif
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"Linked handleAudioFrame in %f ms", linkTime *1000.0);
    return frame;
}

-(NSString*)infoFilePath

{
    
    NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES );
    
    NSString *MyDocpath=[Paths objectAtIndex:0];

    return MyDocpath;
    
}



-(NSString *)currentTime{
    
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd mm:ss"];
    
    NSString *currentString=[dateformatter stringFromDate:currentDate];
    
    return currentString;
    
}



-(void)allWriteToFileWithLocalMac:(NSString *)localMac andRemoteMac:(NSString *)remoteMac andLength:(int)length{
    
    
    
    NSData *buffer;
    
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self infoFilePath]]) {
        
        
        
        NSLog(@"%@",@"文件不存在");
        
        NSString *s = [NSString stringWithFormat:@"开始了:\r"];
        
        [s writeToFile:[self infoFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        
        
    }
    
    
    
    NSString *filePath = [self infoFilePath];
    
    
    
    NSFileHandle  *outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    
    
    if(outFile == nil)
        
    {
        
        NSLog(@"Open of file for writing failed");
        
    }
    
    
    
    //找到并定位到outFile的末尾位置(在此后追加文件)
    
    [outFile seekToEndOfFile];
    
    
    
    //读取inFile并且将其内容写到outFile中
    
    NSString *bs = [NSString stringWithFormat:@"发送数据时间:%@--localMac:%@--remoteMac:%@--length:%d \n",[self currentTime],localMac,remoteMac,length];
    
    buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    [outFile writeData:buffer];
    
    
    
    //关闭读写文件
    
    [outFile closeFile];
    
}

- (CYSubtitleFrame *) handleSubtitle: (AVSubtitle *)pSubtitle
{
    NSMutableString *ms = [NSMutableString string];
    
    for (NSUInteger i = 0; i < pSubtitle->num_rects; ++i) {
       
        AVSubtitleRect *rect = pSubtitle->rects[i];
        if (rect) {
            
            if (rect->text) { // rect->type == SUBTITLE_TEXT
                
                NSString *s = [NSString stringWithUTF8String:rect->text];
                if (s.length) [ms appendString:s];
                
            } else if (rect->ass && _subtitleASSEvents != -1) {
                
                NSString *s = [NSString stringWithUTF8String:rect->ass];
                if (s.length) {
                    
                    NSArray *fields = [CYPlayerSubtitleASSParser parseDialogue:s numFields:_subtitleASSEvents];
                    if (fields.count && [fields.lastObject length]) {
                        
                        s = [CYPlayerSubtitleASSParser removeCommandsFromEventText: fields.lastObject];
                        if (s.length) [ms appendString:s];
                    }                    
                }
            }
        }
    }
    
    if (!ms.length)
        return nil;
    
    CYSubtitleFrame *frame = [[CYSubtitleFrame alloc] init];
    frame.text = [ms copy];   
    frame.position = pSubtitle->pts / AV_TIME_BASE + pSubtitle->start_display_time;
    frame.duration = (CGFloat)(pSubtitle->end_display_time - pSubtitle->start_display_time) / 1000.f;
    
#if 0
    LoggerStream(2, @"SUB: %.4f %.4f | %@",
          frame.position,
          frame.duration,
          frame.text);
#endif
    
    return frame;    
}

- (BOOL) interruptDecoder
{
    if (_interruptCallback)
        return _interruptCallback();
    return NO;
}

#pragma mark - public

- (BOOL) setupVideoFrameFormat: (CYVideoFrameFormat) format
{
    if (format == CYVideoFrameFormatYUV &&
        _videoCodecCtx &&
        (_videoCodecCtx->pix_fmt == AV_PIX_FMT_YUV420P || _videoCodecCtx->pix_fmt == AV_PIX_FMT_YUVJ420P)) {
        
        _videoFrameFormat = CYVideoFrameFormatYUV;
        return YES;
    }
    
    _videoFrameFormat = CYVideoFrameFormatRGB;
    return _videoFrameFormat == format;
}

- (NSArray *) old_decodeFrames: (CGFloat) minDuration
{
    if (_videoStream == -1 &&
        _audioStream == -1)
        return nil;

    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    
    CGFloat decodedDuration = 0;
    
    BOOL finished = NO;
    
    while (!finished && _formatCtx) {
        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        if (av_read_frame(_formatCtx, &packet) < 0) {
            _isEOF = YES;
            av_packet_unref(&packet);
            break;
        }
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Linked av_read_frame in %f ms", linkTime *1000.0);
        
        if (packet.stream_index ==_videoStream && self.decodeType & CYVideoDecodeTypeVideo) {
           
            int pktSize = packet.size;
            
            while (pktSize > 0 && _videoCodecCtx) {
                            
                int gotframe = 0;
                int len = avcodec_send_packet(_videoCodecCtx, &packet);
                gotframe = !avcodec_receive_frame(_videoCodecCtx, _videoFrame);
                
                if (len < 0) {
                    LoggerVideo(0, @"decode video error, skip packet");
                    break;
                }
                
                if (gotframe) {
                    
                    CYVideoFrame *frame = [self handleVideoFrame:_videoFrame Picture:&_picture isPictureValid:&_pictureValid];
                    if (frame) {
                        
                        [result addObject:frame];
                        
                        if (frame.position >= _position)
                        {
                            _position = _position + frame.duration;
                            decodedDuration += frame.duration;
                        }
                        
                        if (decodedDuration > minDuration)
                            finished = YES;
                    }
                }
                                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
            
        } else if (packet.stream_index == _audioStream && self.decodeType & CYVideoDecodeTypeAudio) {
                        
            int pktSize = packet.size;
            
            while (pktSize > 0 && _audioCodecCtx) {
                
                int gotframe = 0;
                
                int len = avcodec_send_packet(_audioCodecCtx, &packet);
                gotframe = !avcodec_receive_frame(_audioCodecCtx, _audioFrame);
                
                if (len < 0) {
                    LoggerAudio(0, @"decode audio error, skip packet");
                    break;
                }
                
                if (gotframe) {
                    
                    CYAudioFrame * frame = [self handleAudioFrame:_audioFrame];
                    if (frame) {
                        
                        [result addObject:frame];
                                                
                        if (_videoStream == -1) {
                            
//                            _position = frame.position;
//                            decodedDuration += frame.duration;
                            if (frame.position >= _position)
                            {
                                _position = _position + frame.duration;
                                decodedDuration += frame.duration;
                            }
                            if (decodedDuration > minDuration)
                                finished = YES;
                        }
                    }
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
            
        } else if (packet.stream_index == _artworkStream) {
            
            if (packet.size) {

                CYArtworkFrame *frame = [[CYArtworkFrame alloc] init];
                frame.picture = [NSData dataWithBytes:packet.data length:packet.size];
                [result addObject:frame];
            }
            
        } else if (packet.stream_index == _subtitleStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                AVSubtitle subtitle;
                int gotsubtitle = 0;
                int len = avcodec_decode_subtitle2(_subtitleCodecCtx,
                                                  &subtitle,
                                                  &gotsubtitle,
                                                  &packet);
                
                if (len < 0) {
                    LoggerStream(0, @"decode subtitle error, skip packet");
                    break;
                }
                
                if (gotsubtitle) {
                    
                    CYSubtitleFrame *frame = [self handleSubtitle: &subtitle];
                    if (frame) {
                        [result addObject:frame];
                    }
                    avsubtitle_free(&subtitle);
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
        }
        av_packet_unref(&packet);
//        av_free_packet(&packet);
	}
    av_packet_unref(&packet);
    
    return result;
}

- (NSArray *) decodeFrames: (CGFloat) minDuration
{
    if (_videoStream == -1 &&
        _audioStream == -1)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    
    CGFloat decodedDuration = 0;
    
    BOOL finished = NO;
    
    while (!finished && _formatCtx) {
        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        if (av_read_frame(_formatCtx, &packet) < 0) {
            _isEOF = YES;
            av_packet_unref(&packet);
            break;
        }
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Linked av_read_frame in %f ms", linkTime *1000.0);
        
        CYPlayerFrame * frame = [self handlePacket:packet audioFrame:_audioFrame videoFrame:_videoFrame picture:&_picture isPictureValid:&_pictureValid];
        if (frame)
        {
            [result addObject:frame];
            if (_videoStream == -1) {
                if (frame.position >= _position)
                {
                    _position = _position + frame.duration;
                    decodedDuration += frame.duration;
                }
                if (decodedDuration > minDuration)
                    finished = YES;
            }
            else
            {
                if (frame.type == CYPlayerFrameTypeVideo)
                {
                    if (frame.position >= _position)
                    {
                        _position = _position + frame.duration;
                        decodedDuration += frame.duration;
                    }
                }
                
                if (decodedDuration > minDuration)
                    finished = YES;
            }
        }
        
        
        av_packet_unref(&packet);
    }
    av_packet_unref(&packet);
    
    return result;
}

- (NSArray *) decodeFrames5: (CGFloat) minDuration
{
    if (_videoStream == -1 &&
        _audioStream == -1)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    
    CGFloat decodedDuration = 0;
    
    BOOL finished = NO;
    
    while (!finished && _formatCtx) {
        CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
        if (av_read_frame(_formatCtx, &packet) < 0) {
            _isEOF = YES;
            av_packet_unref(&packet);
            break;
        }
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Linked av_read_frame in %f ms", linkTime *1000.0);
        
        CYPlayerFrame * frame = [self handlePacket:packet audioFrame:_audioFrame videoFrame:_videoFrame picture:&_picture isPictureValid:&_pictureValid];
        if (frame)
        {
            [result addObject:frame];
            if (_videoStream == -1) {
                if (frame.position >= _position)
                {
                    _position = _position + frame.duration;
                    decodedDuration += frame.duration;
                }
                if (decodedDuration > minDuration)
                    finished = YES;
            }
            else
            {
                if (frame.type == CYPlayerFrameTypeVideo)
                {
                    if (frame.position >= _position)
                    {
                        _position = _position + frame.duration;
                        decodedDuration += frame.duration;
                    }
                }
                
                if (decodedDuration > minDuration)
                    finished = YES;
            }
        }
        
        
        av_packet_unref(&packet);
    }
    av_packet_unref(&packet);
    
    return result;
}

- (CYPlayerFrame *)handlePacket:(AVPacket)packet audioFrame:(AVFrame *)audioFrame videoFrame:(AVFrame *)videoFrame picture:(AVPicture *)picture isPictureValid:(BOOL *)isPictureValid
{
    CYPlayerFrame * result_frame = nil;
    if (packet.stream_index ==_videoStream && self.decodeType & CYVideoDecodeTypeVideo) {
        
        int pktSize = packet.size;
        
        while (pktSize > 0 && _videoCodecCtx) {
            
            int gotframe = 0;
            int len = avcodec_send_packet(_videoCodecCtx, &packet);
            gotframe = !avcodec_receive_frame(_videoCodecCtx, _videoFrame);
            
            if (len < 0) {
                LoggerVideo(0, @"decode video error, skip packet");
                break;
            }
            
            if (gotframe) {
                
                CYVideoFrame *frame = [self handleVideoFrame:videoFrame Picture:picture isPictureValid:isPictureValid];
                if (frame) {
                    
                    result_frame = frame;
                }
            }
            
            if (0 == len)
                break;
            
            pktSize -= len;
        }
        
    } else if (packet.stream_index == _audioStream && self.decodeType & CYVideoDecodeTypeAudio) {
        
        int pktSize = packet.size;
        
        while (pktSize > 0 && _audioCodecCtx) {
            
            int gotframe = 0;
            
            int len = avcodec_send_packet(_audioCodecCtx, &packet);
            gotframe = !avcodec_receive_frame(_audioCodecCtx, _audioFrame);
            
            if (len < 0) {
                LoggerAudio(0, @"decode audio error, skip packet");
                break;
            }
            
            if (gotframe) {
                
                CYAudioFrame * frame = [self handleAudioFrame:audioFrame];
                if (frame) {
                    
                    result_frame = frame;
                }
            }
            
            if (0 == len)
                break;
            
            pktSize -= len;
        }
        
    } else if (packet.stream_index == _artworkStream) {
        
        if (packet.size) {
            
            CYArtworkFrame *frame = [[CYArtworkFrame alloc] init];
            frame.picture = [NSData dataWithBytes:packet.data length:packet.size];
            if (frame)
            {
                result_frame = frame;
            }
        }
        
    } else if (packet.stream_index == _subtitleStream) {
        
        int pktSize = packet.size;
        
        while (pktSize > 0) {
            
            AVSubtitle subtitle;
            int gotsubtitle = 0;
            int len = avcodec_decode_subtitle2(_subtitleCodecCtx,
                                               &subtitle,
                                               &gotsubtitle,
                                               &packet);
            
            if (len < 0) {
                LoggerStream(0, @"decode subtitle error, skip packet");
                break;
            }
            
            if (gotsubtitle) {
                
                CYSubtitleFrame *frame = [self handleSubtitle: &subtitle];
                if (frame) {
                    result_frame = frame;
                }
                avsubtitle_free(&subtitle);
            }
            
            if (0 == len)
                break;
            
            pktSize -= len;
        }
    }

    return result_frame;
}

- (NSArray *) decodeTargetFrames: (CGFloat) minDuration :(CGFloat)targetPos
{
    if (_videoStream == -1 &&
        _audioStream == -1)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    
    CGFloat decodedDuration = 0;
    
    BOOL finished = NO;
    
    while (!finished && _formatCtx) {

        if (av_read_frame(_formatCtx, &packet) < 0) {
            _isEOF = YES;
            av_packet_unref(&packet);
            break;
        }
        
         if (packet.stream_index == _audioStream && self.decodeType & CYVideoDecodeTypeAudio) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0 && _audioCodecCtx) {
                
                int gotframe = 0;
                int len = avcodec_send_packet(_audioCodecCtx, &packet);
                gotframe = !avcodec_receive_frame(_audioCodecCtx, _audioFrame);
                
                if (len < 0) {
                    LoggerAudio(0, @"decode audio error, skip packet");
                    break;
                }
                
                if (gotframe) {
                    CGFloat curr_position = av_frame_get_best_effort_timestamp(_audioFrame) * _audioTimeBase;
                    if (curr_position >= targetPos)
                    {
                        CYAudioFrame * frame = [self handleAudioFrame:_audioFrame];
                        if (frame) {
                            
                            [result addObject:frame];
                            
                            if (_videoStream == -1) {
                                
                                _position = frame.position;
                                decodedDuration += frame.duration;
                                if (decodedDuration > minDuration)
                                    finished = YES;
                            }
                        }
                    }
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
            
         } else if (packet.stream_index ==_videoStream && self.decodeType & CYVideoDecodeTypeVideo) {
             
             int pktSize = packet.size;
             
             while (pktSize > 0 && _videoCodecCtx) {
                 
                 int gotframe = 0;
                 //                int len = avcodec_decode_video2(_videoCodecCtx,
                 //                                                _videoFrame,
                 //                                                &gotframe,
                 //                                                &packet);
                 int len = avcodec_send_packet(_videoCodecCtx, &packet);
                 gotframe = !avcodec_receive_frame(_videoCodecCtx, _videoFrame);
                 
                 if (len < 0) {
                     LoggerVideo(0, @"decode video error, skip packet");
                     break;
                 }
                 
                 if (gotframe) {
                     CGFloat curr_position = av_frame_get_best_effort_timestamp(_videoFrame) * _videoTimeBase;
                     if (curr_position >= targetPos)
                     {
                         CYVideoFrame *frame = [self handleVideoFrame:_videoFrame Picture:&_picture isPictureValid:&_pictureValid];
                         if (frame) {
                             
                             [result addObject:frame];
                             
                             _position = frame.position;
                             decodedDuration += frame.duration;
                             if (decodedDuration > minDuration)
                                 finished = YES;
                         }
                     }
                 }
                 
                 if (0 == len)
                     break;
                 
                 pktSize -= len;
             }
             
         } else if (packet.stream_index == _artworkStream) {
            
            if (packet.size) {
                
                CYArtworkFrame *frame = [[CYArtworkFrame alloc] init];
                frame.picture = [NSData dataWithBytes:packet.data length:packet.size];
                [result addObject:frame];
            }
            
        } else if (packet.stream_index == _subtitleStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                AVSubtitle subtitle;
                int gotsubtitle = 0;
                int len = avcodec_decode_subtitle2(_subtitleCodecCtx,
                                                   &subtitle,
                                                   &gotsubtitle,
                                                   &packet);
                
                if (len < 0) {
                    LoggerStream(0, @"decode subtitle error, skip packet");
                    break;
                }
                if (gotsubtitle) {
                    CGFloat curr_position = subtitle.pts / AV_TIME_BASE + subtitle.start_display_time;
                    if (curr_position >= targetPos)
                    {
                        CYSubtitleFrame *frame = [self handleSubtitle: &subtitle];
                        if (frame) {
                            [result addObject:frame];
                        }
                    }
                }
                avsubtitle_free(&subtitle);
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
        }
        av_packet_unref(&packet);
    }
    av_packet_unref(&packet);
    
    return result;
}

# pragma mark - NotificationCenter

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    dispatch_semaphore_wait(_swrContextLock, DISPATCH_TIME_FOREVER);
    CYPCMAudioManager * audioManager = [CYPCMAudioManager audioManager];
    int64_t audioChannel = av_get_default_channel_layout((int)(audioManager.avcodecContextNumOutputChannels));
    int64_t swrcontext_channel;
    av_opt_get_int(_swrContext, "out_channel_layout", 0, &swrcontext_channel);
    if (audioChannel != swrcontext_channel)
    {
        BOOL result = audio_swr_resampling_audio_init(&_swrContext, _audioCodecCtx);
        if (!result)
        {
            
        }
    }
    dispatch_semaphore_signal(_swrContextLock);
}

@end

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

static int interrupt_callback(void *ctx)
{
    if (!ctx)
        return 0;
    __unsafe_unretained CYPlayerDecoder *p = (__bridge CYPlayerDecoder *)ctx;
    const BOOL r = [p interruptDecoder];
    if (r) LoggerStream(1, @"DEBUG: INTERRUPT_CALLBACK!");
    return r;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

@implementation CYPlayerSubtitleASSParser

+ (NSArray *) parseEvents: (NSString *) events
{
    NSRange r = [events rangeOfString:@"[Events]"];
    if (r.location != NSNotFound) {
        
        NSUInteger pos = r.location + r.length;
        
        r = [events rangeOfString:@"Format:"
                          options:0
                            range:NSMakeRange(pos, events.length - pos)];
        
        if (r.location != NSNotFound) {
            
            pos = r.location + r.length;
            r = [events rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                        options:0
                                          range:NSMakeRange(pos, events.length - pos)];
            
            if (r.location != NSNotFound) {
                
                NSString *format = [events substringWithRange:NSMakeRange(pos, r.location - pos)];
                NSArray *fields = [format componentsSeparatedByString:@","];
                if (fields.count > 0) {
                    
                    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
                    NSMutableArray *ma = [NSMutableArray array];
                    for (NSString *s in fields) {
                        [ma addObject:[s stringByTrimmingCharactersInSet:ws]];
                    }
                    return ma;
                }
            }
        }
    }
    
    return nil;
}

+ (NSArray *) parseDialogue: (NSString *) dialogue
                  numFields: (NSUInteger) numFields
{
    if ([dialogue hasPrefix:@"Dialogue:"]) {
        
        NSMutableArray *ma = [NSMutableArray array];
        
        NSRange r = {@"Dialogue:".length, 0};
        NSUInteger n = 0;
        
        while (r.location != NSNotFound && n++ < numFields) {
            
            const NSUInteger pos = r.location + r.length;
            
            r = [dialogue rangeOfString:@","
                                options:0
                                  range:NSMakeRange(pos, dialogue.length - pos)];
            
            const NSUInteger len = r.location == NSNotFound ? dialogue.length - pos : r.location - pos;
            NSString *p = [dialogue substringWithRange:NSMakeRange(pos, len)];
            p = [p stringByReplacingOccurrencesOfString:@"\\N" withString:@"\n"];
            [ma addObject: p];
        }
        
        return ma;
    }
    
    return nil;
}

+ (NSString *) removeCommandsFromEventText: (NSString *) text
{
    NSMutableString *ms = [NSMutableString string];
    
    NSScanner *scanner = [NSScanner scannerWithString:text];
    while (!scanner.isAtEnd) {
        
        NSString *s;
        if ([scanner scanUpToString:@"{\\" intoString:&s]) {
            
            [ms appendString:s];
        }
        
        if (!([scanner scanString:@"{\\" intoString:nil] &&
              [scanner scanUpToString:@"}" intoString:nil] &&
              [scanner scanString:@"}" intoString:nil])) {
            
            break;
        }
    }
    
    return ms;
}
    

@end

static void FFLog(void* context, int level, const char* format, va_list args) {
    @autoreleasepool {
        //Trim time at the beginning and new line at the end
        NSString* message = [[NSString alloc] initWithFormat: [NSString stringWithUTF8String: format] arguments: args];
        switch (level) {
            case 0:
            case 1:
                LoggerStream(0, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            case 2:
                LoggerStream(1, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            case 3:
            case 4:
                LoggerStream(2, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            default:
                LoggerStream(3, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
        }
    }
}

