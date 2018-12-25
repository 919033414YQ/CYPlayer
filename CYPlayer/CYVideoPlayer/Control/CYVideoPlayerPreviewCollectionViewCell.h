//
//  CYVideoPlayerPreviewCollectionViewCell.h
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/12/4.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYVideoPreviewModel, CYFFmpegPreviewModel;

@interface CYVideoPlayerPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readwrite, nullable) CYVideoPreviewModel *model;

@property (nonatomic, strong, readwrite, nullable) CYFFmpegPreviewModel *ffmpegModel;

@end

NS_ASSUME_NONNULL_END
