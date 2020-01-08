//
//  CYTest.m
//  CYPlayer
//
//  Created by 黄威 on 2018/8/16.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import "CYTest.h"
#import <CYFFmpeg/CYFFmpeg.h>
//#import "x264.h"


@implementation CYTest

- (void)test
{
//    smbc_init_context(NULL);
//    smbc_get_auth_data_fn fn;
//    int debug;
//    smbc_init(fn, debug);
    
//    x264_encoder_encode(NULL, NULL, NULL, NULL, NULL);
    
    avcodec_open2(NULL, NULL, NULL);
}

@end
