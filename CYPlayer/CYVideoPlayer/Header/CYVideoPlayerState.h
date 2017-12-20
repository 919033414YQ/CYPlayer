//
//  CYVideoPlayerState.h
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#ifndef CYVideoPlayerState_h
#define CYVideoPlayerState_h

typedef NS_ENUM(NSUInteger, CYVideoPlayerPlayState) {
    CYVideoPlayerPlayState_Unknown = 0,
    CYVideoPlayerPlayState_Prepare,
    CYVideoPlayerPlayState_Playing,
    CYVideoPlayerPlayState_Buffing,
    CYVideoPlayerPlayState_Pause,
    CYVideoPlayerPlayState_PlayEnd,
    CYVideoPlayerPlayState_PlayFailed,
};

#endif /* CYVideoPlayerState_h */
