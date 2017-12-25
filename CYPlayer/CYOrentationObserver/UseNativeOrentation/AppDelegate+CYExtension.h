//
//  AppDelegate+CYExtension.h
//  CYPlayer
//
//  Created by 黄威 on 2017/12/25.
//  Copyright © 2017年 黄威. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (CYExtension)

@property (nonatomic, assign, readwrite, getter=isLockRotation) BOOL lockRotation;

@property (nonatomic, assign, readwrite, getter=isAllowRotation) BOOL allowRotation;
@end
