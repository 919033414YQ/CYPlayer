//
//  CYVideoPlayerPresentView.h
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CYVideoPlayerAssetCarrier;

NS_ASSUME_NONNULL_BEGIN

@interface CYVideoPlayerPresentView : UIView

- (AVPlayerLayer *)avLayer;

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;

@property (nonatomic, strong, readwrite) AVLayerVideoGravity videoGravity;

@property (nonatomic, weak, readwrite, nullable) CYVideoPlayerAssetCarrier *asset;

@property (nonatomic, copy, readwrite, nullable) void(^readyForDisplay)(CYVideoPlayerPresentView *view);

@end

NS_ASSUME_NONNULL_END
