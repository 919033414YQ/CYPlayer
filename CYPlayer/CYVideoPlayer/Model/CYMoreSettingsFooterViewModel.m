//
//  CYMoreSettingsFooterViewModel.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYMoreSettingsFooterViewModel.h"
#import <AVFoundation/AVPlayer.h>

@interface CYMoreSettingsFooterViewModel ()

@end

@implementation CYMoreSettingsFooterViewModel

- (instancetype)initWithAVPlayer:(AVPlayer *__weak)player {
    self = [super init];
    if ( !self ) return nil;
    return self;
}

@end
