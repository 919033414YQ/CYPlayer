//
//  CYVideoPlayerControlView.m
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/11/29.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "CYVideoPlayerControlView.h"
#import "CYVideoPlayerAssetCarrier.h"
#import <Masonry/Masonry.h>
#import "CYVideoPlayerResources.h"
#import "CYMovieDecoder.h"

@interface CYVideoPlayerControlView()<CYVideoPlayerTopControlViewDelegate, CYVideoPlayerLeftControlViewDelegate, CYVideoPlayerCenterControlViewDelegate, CYVideoPlayerBottomControlViewDelegate, CYVideoPlayerPreviewViewDelegate>
@end

@implementation CYVideoPlayerControlView
@synthesize bottomProgressSlider = _bottomProgressSlider;
@synthesize previewView = _previewView;
@synthesize topControlView = _topControlView;
@synthesize leftControlView = _leftControlView;
@synthesize centerControlView = _centerControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize draggingProgressView = _draggingProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlSetupView];
    _topControlView.delegate = self;
    _leftControlView.delegate = self;
    _centerControlView.delegate = self;
    _bottomControlView.delegate = self;
    _previewView.delegate = self;
    __weak typeof(self) _self = self;
    self.setting = ^(CYVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomProgressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomProgressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    };
    return self;
}

- (void)setAsset:(CYVideoPlayerAssetCarrier *)asset {
    _asset = asset;
    _draggingProgressView.asset = asset;
}

- (void)setDecoder:(CYMovieDecoder *)decoder
{
    _decoder = decoder;
    _draggingProgressView.decoder = decoder;
}

#pragma mark

- (void)_controlSetupView {
    [self.containerView addSubview:self.draggingProgressView];
    [self.containerView addSubview:self.topControlView];
    [self.containerView addSubview:self.leftControlView];
    [self.containerView addSubview:self.centerControlView];
    [self.containerView addSubview:self.bottomControlView];
    [self.containerView addSubview:self.previewView];
    [self.containerView addSubview:self.bottomProgressSlider];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.offset(0);
        make.height.equalTo(@(CYControlTopH));
    }];
    
    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topControlView.previewBtn.mas_bottom).offset(12);
        make.leading.trailing.offset(0);
        make.height.offset([UIScreen mainScreen].bounds.size.width * 0.25);
    }];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.offset(CYControlLeftH);
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    [_centerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(_centerControlView.superview).multipliedBy(0.382);
        make.height.equalTo(_centerControlView.mas_width);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.offset(0);
        make.height.offset(CYControlBottomH);
    }];
    
    [_bottomProgressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(1);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_draggingProgressView.superview);
    }];
}

- (CYVideoPlayerTopControlView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [CYVideoPlayerTopControlView new];
    return _topControlView;
}

- (CYVideoPlayerLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [CYVideoPlayerLeftControlView new];
    return _leftControlView;
}

- (CYVideoPlayerCenterControlView *)centerControlView {
    if ( _centerControlView ) return _centerControlView;
    _centerControlView = [CYVideoPlayerCenterControlView new];
    return _centerControlView;
}

- (CYVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [CYVideoPlayerBottomControlView new];
    return _bottomControlView;
}

- (CYVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [CYVideoPlayerDraggingProgressView new];
    return _draggingProgressView;
}

#pragma mark
- (void)topControlView:(CYVideoPlayerTopControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)leftControlView:(CYVideoPlayerLeftControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)centerControlView:(CYVideoPlayerCenterControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)bottomControlView:(CYVideoPlayerBottomControlView *)view clickedBtnTag:(CYVideoPlayControlViewTag)tag {
    if ( ![_delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [_delegate controlView:self clickedBtnTag:tag];
}

- (void)previewView:(CYVideoPlayerPreviewView *)view didSelectItem:(CYVideoPreviewModel *)item {
    if ( ![_delegate respondsToSelector:@selector(controlView:didSelectPreviewItem:)] ) return;
    [_delegate controlView:self didSelectPreviewItem:item];
}

- (void)previewView:(CYVideoPlayerPreviewView *)view didSelectFrame:(CYVideoFrame *)frame
{
    if ( ![_delegate respondsToSelector:@selector(controlView:didSelectPreviewFrame:)] ) return;
    [_delegate controlView:self didSelectPreviewFrame:frame];
}

- (CYVideoPlayerPreviewView *)previewView {
    if ( _previewView ) return _previewView;
    _previewView = [CYVideoPlayerPreviewView new];
    _previewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    return _previewView;
}
- (CYSlider *)bottomProgressSlider {
    if ( _bottomProgressSlider ) return _bottomProgressSlider;
    _bottomProgressSlider = [CYSlider new];
    _bottomProgressSlider.trackHeight = 1;
    _bottomProgressSlider.pan.enabled = NO;
    return _bottomProgressSlider;
}

@end
