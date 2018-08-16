//
//  CYTest.m
//  CYPlayer
//
//  Created by 黄威 on 2018/8/16.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import "CYTest.h"
#import "libsmbclient.h"


@implementation CYTest

- (void)test
{
    smbc_init_context(NULL);
    smbc_get_auth_data_fn fn;
    int debug;
    smbc_init(fn, debug);
}

@end
