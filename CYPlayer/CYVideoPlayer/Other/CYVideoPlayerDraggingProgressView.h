//
//  CYVideoPlayerDraggingProgressView.h
//  CYVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "CYVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class CYSlider;

@interface CYVideoPlayerDraggingProgressView : CYVideoPlayerBaseView

@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) CYSlider *progressSlider;

@end

NS_ASSUME_NONNULL_END
