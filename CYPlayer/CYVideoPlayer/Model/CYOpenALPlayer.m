//
//  CYOpenALPlayer.m
//  CYPlayer
//
//  Created by 黄威 on 2018/8/31.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import "CYOpenALPlayer.h"

@implementation CYOpenALPlayer{
    
    ALCdevice  * m_Devicde;          //device句柄
    ALCcontext * m_Context;         //device context
    ALuint       m_outSourceId;           //source id 负责播放
    NSLock     * lock;
    float        rate;
    
}


-(int)initOpenAL{
    int ret = 0;
    if (m_Devicde == NULL)
    {
        lock = [[NSLock alloc]init];
        printf("=======initOpenAl===\n");
        rate = 1.0;
        m_Devicde = alcOpenDevice(NULL);
        if (m_Devicde)
        {
            //建立声音文本描述
            m_Context = alcCreateContext(m_Devicde, NULL);
            //设置行为文本描述
            alcMakeContextCurrent(m_Context);
        }else
            ret = -1;
        
        //创建一个source并设置一些属性
        alGenSources(1, &m_outSourceId);
        alSpeedOfSound(1.0);
        alDopplerVelocity(1.0);
        alDopplerFactor(1.0);
        alSourcef(m_outSourceId, AL_PITCH, 1.0f);
        alSourcef(m_outSourceId, AL_GAIN, 1.0f);
        alSourcei(m_outSourceId, AL_LOOPING, AL_FALSE);
        alSourcef(m_outSourceId, AL_SOURCE_TYPE, AL_STREAMING);
    }
    return ret;
}

-(int)updataQueueBuffer{
    
    
    //播放状态字段
    ALint stateVaue = 0;
    
    //获取处理队列，得出已经播放过的缓冲器的数量
    alGetSourcei(m_outSourceId, AL_BUFFERS_PROCESSED, &_m_numprocessed);
    //获取缓存队列，缓存的队列数量
    alGetSourcei(m_outSourceId, AL_BUFFERS_QUEUED, &_m_numqueued);
    
    //获取播放状态，是不是正在播放
    alGetSourcei(m_outSourceId, AL_SOURCE_STATE, &stateVaue);
    
    //printf("===statevaue ========================%x\n",stateVaue);
    
    if (stateVaue == AL_STOPPED ||
        stateVaue == AL_PAUSED ||
        stateVaue == AL_INITIAL)
    {
        //如果没有数据,或数据播放完了
        if (_m_numqueued < _m_numprocessed ||
            _m_numqueued == 0 ||
            (_m_numqueued == 1 && _m_numprocessed ==1))
        {
            //停止播放
            printf("...Audio Stop\n");
            [self stopSound];;
//            [self cleanUpOpenAL];
            return 0;
        }
        
        if (stateVaue != AL_PLAYING)
        {
            [self playSound];
        }
    }
    
    //将已经播放过的的数据删除掉
    while((_m_numprocessed --) && _m_numprocessed > 0)
    {
        ALuint buff;
        //更新缓存buffer中的数据到source中
        alSourceUnqueueBuffers(m_outSourceId, 1, &buff);
        //删除缓存buff中的数据
        alDeleteBuffers(1, &buff);
        
        //得到已经播放的音频队列多少块
        _m_IsplayBufferSize ++;
    }
    
    return 1;
}

-(void)cleanUpOpenAL{
    
    printf("=======cleanUpOpenAL===\n");
    alDeleteSources(1, &m_outSourceId);
    
    ALCcontext * Context = alcGetCurrentContext();
    // ALCdevice * Devicde = alcGetContextsDevice(Context);
    
    if (Context)
    {
        alcMakeContextCurrent(NULL);
        alcDestroyContext(Context);
        m_Context = NULL;
    }
    alcCloseDevice(m_Devicde);
    m_Devicde = NULL;
}

-(void)playSound{
    
    int ret = 0;
    
    alSourcePlay(m_outSourceId);
    if((ret = alGetError()) != AL_NO_ERROR)
    {
        printf("error alcMakeContextCurrent %x\n", ret);
    }
}

-(void)stopSound
{
    alSourceStop(m_outSourceId);
}

-(int)openAudioFromQueue:(char*)data
         andWithDataSize:(int)dataSize
       andWithSampleRate:(int)aSampleRate
             andWithAbit:(int)aBit
         andWithAchannel:(int)aChannel{
    
    int ret = 0;
    //样本数openal的表示方法
    ALenum format = 0;
    //buffer id 负责缓存,要用局部变量每次数据都是新的地址
    ALuint bufferID = 0;
    
    if (_m_datasize == 0 &&
        _m_samplerate == 0 &&
        _m_bit == 0 &&
        _m_channel == 0)
    {
        if (dataSize != 0 &&
            aSampleRate != 0 &&
            aBit != 0 &&
            aChannel != 0)
        {
            _m_datasize = dataSize;
            _m_samplerate = aSampleRate;
            _m_bit = aBit;
            _m_channel = aChannel;
            _m_oneframeduration = _m_datasize * 1.0 /(_m_bit/8) /_m_channel /_m_samplerate * 1000 ;   //计算一帧数据持续时间
        }
    }
    
    //创建一个buffer
    alGenBuffers(1, &bufferID);
    if((ret = alGetError()) != AL_NO_ERROR)
    {
        printf("error alGenBuffers %x \n", ret);
        // printf("error alGenBuffers %x : %s\n", ret,alutGetErrorString (ret));
        //AL_ILLEGAL_ENUM
        //AL_INVALID_VALUE
        //#define AL_ILLEGAL_COMMAND                        0xA004
        //#define AL_INVALID_OPERATION                      0xA004
    }
    
    if (aBit == 8)
    {
        if (aChannel == 1)
        {
            format = AL_FORMAT_MONO8;
        }
        else if(aChannel == 2)
        {
            format = AL_FORMAT_STEREO8;
        }
    }
    
    if( aBit == 16 )
    {
        if( aChannel == 1 )
        {
            format = AL_FORMAT_MONO16;
        }
        if( aChannel == 2 )
        {
            format = AL_FORMAT_STEREO16;
        }
    }
    //指定要将数据复制到缓冲区中的数据
    alBufferData(bufferID, format, data, dataSize,aSampleRate);
    if((ret = alGetError()) != AL_NO_ERROR)
    {
        printf("error alBufferData %x\n", ret);
        //AL_ILLEGAL_ENUM
        //AL_INVALID_VALUE
        //#define AL_ILLEGAL_COMMAND                        0xA004
        //#define AL_INVALID_OPERATION                      0xA004
    }
    //附加一个或一组buffer到一个source上
    alSourceQueueBuffers(m_outSourceId, 1, &bufferID);
    if((ret = alGetError()) != AL_NO_ERROR)
    {
        printf("error alSourceQueueBuffers %x\n", ret);
    }
    
    //更新队列数据
    ret = [self updataQueueBuffer];
    
    bufferID = 0;
    
    return ret;
}

- (void)setM_volume:(float)m_volume{
    
    self.m_volume = m_volume;
    alSourcef(m_outSourceId,AL_GAIN,m_volume);
}

- (float)m_volume{
    return self.m_volume;
}

-(void)setPlayRate:(double)playRate{
    
    alSourcef(m_outSourceId, AL_PITCH, playRate);
}

- (void)dealloc
{
    [self cleanUpOpenAL];
    NSLog(@"CYOpenALPlayer dealloc");
}

@end
