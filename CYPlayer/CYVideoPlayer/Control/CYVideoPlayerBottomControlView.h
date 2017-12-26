//
//  CYVideoPlayerBottomControlView.h
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/11/29.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "CYVideoPlayerBaseView.h"
#import "CYSlider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CYVideoPlayerBottomControlViewDelegate;

@interface CYVideoPlayerBottomControlView : CYVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<CYVideoPlayerBottomControlViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;
@property (nonatomic, strong, readonly) CYSlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *fullBtn;

@end

@protocol CYVideoPlayerBottomControlViewDelegate <NSObject>
			
@optional
- (void)bottomControlView:(CYVideoPlayerBottomControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
