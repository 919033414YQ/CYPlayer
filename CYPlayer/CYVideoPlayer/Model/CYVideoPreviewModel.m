//
//  CYVideoPreviewModel.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYVideoPreviewModel.h"

@interface CYVideoPreviewModel ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CMTime localTime;

@end

@implementation CYVideoPreviewModel

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time {
    CYVideoPreviewModel *model = [self new];
    model.image = image;
    model.localTime = time;
    return model;
}

@end

