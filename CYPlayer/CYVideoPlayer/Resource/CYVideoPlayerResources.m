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
    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"CYVideoPlayer.bundle" stringByAppendingPathComponent:imageName];
}

+ (NSBundle *)bundle
{
    NSString * bundle_path = [NSBundle bundleForClass:NSClassFromString(@"CYVideoPlayer")].resourcePath;
    bundle_path = [bundle_path stringByAppendingPathComponent:@"CYVideoPlayer.bundle"];
    NSBundle * bundle = [NSBundle bundleWithPath:bundle_path];
    return bundle;
}

@end
