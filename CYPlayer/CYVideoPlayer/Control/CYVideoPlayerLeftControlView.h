//
//  CYVideoPlayerLeftControlView.h
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CYVideoPlayerLeftControlViewDelegate;

@interface CYVideoPlayerLeftControlView : CYVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<CYVideoPlayerLeftControlViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *lockBtn;
@property (nonatomic, strong, readonly) UIButton *unlockBtn;

@end

@protocol CYVideoPlayerLeftControlViewDelegate <NSObject>
			
@optional
- (void)leftControlView:(CYVideoPlayerLeftControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
