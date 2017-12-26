//
//  CYVideoPlayerResources.m
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/11/29.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "CYVideoPlayerResources.h"

@implementation CYVideoPlayerResources

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:[self bundleComponentWithImageName:name]];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"CYVideoPlayer.bundle" stringByAppendingPathComponent:imageName];
}

@end
