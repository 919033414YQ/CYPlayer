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
//    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
    return [self imageNamed:name ofBundle:@"CYVideoPlayer.bundle"];
}

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    
    UIImage *image = nil;
    
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];;
    
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return image;
    
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
