//
//  CYVideoPlayerBottomControlView.m
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/11/29.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "CYVideoPlayerBottomControlView.h"
#import "CYUIFactory.h"
#import "CYVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import "CYVideoPlayerControlMaskView.h"

@interface CYVideoPlayerBottomControlView ()

@property (nonatomic, strong, readonly) CYVideoPlayerControlMaskView *controlMaskView;

@end

@implementation CYVideoPlayerBottomControlView
@synthesize controlMaskView = _controlMaskView;
@synthesize separateLabel = _separateLabel;
@synthesize durationTimeLabel = _durationTimeLabel;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize progressSlider = _progressSlider;
@synthesize fullBtn = _fullBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _bottomSetupView];
    __weak typeof(self) _self = self;
    self.setting = ^(CYVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.playBtn setImage:setting.playBtnImage forState:UIControlStateNormal];
        [self.pauseBtn setImage:setting.pauseBtnImage forState:UIControlStateNormal];
        [self.fullBtn setImage:setting.fullBtnImage_nor forState:UIControlStateNormal];
        [self.fullBtn setImage:setting.fullBtnImage_sel forState:UIControlStateSelected];
        self.progressSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.progressSlider.trackImageView.backgroundColor = setting.progress_trackColor;
        self.progressSlider.thumbImageView.image = setting.progress_thumbImage_nor;
        self.progressSlider.thumbnail_nor = setting.progress_thumbImage_nor;
        self.progressSlider.thumbnail_sel = setting.progress_thumbImage_sel;
        self.progressSlider.bufferProgressColor = setting.progress_bufferColor;
        self.progressSlider.trackHeight = setting.progress_traceHeight;
        if (setting.enableProgressControl)
        {
            self.progressSlider.hidden = NO;
            self.separateLabel.hidden = NO;
            self.durationTimeLabel.hidden = NO;
            self.currentTimeLabel.hidden = NO;
            self.playBtn.hidden = NO;
            self.pauseBtn.hidden = NO;
        }
        else
        {
            self.progressSlider.hidden = YES;
            self.separateLabel.hidden = YES;
            self.durationTimeLabel.hidden = YES;
            self.currentTimeLabel.hidden = NO;
            self.playBtn.hidden = NO;
            self.pauseBtn.hidden = NO;
        }
    };
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(bottomControlView:clickedBtnTag:)] ) return;
    [_delegate bottomControlView:self clickedBtnTag:btn.tag];
}

- (void)_bottomSetupView {
    [self.containerView addSubview:self.controlMaskView];
    [self.containerView addSubview:self.playBtn];
    [self.containerView addSubview:self.pauseBtn];
    [self.containerView addSubview:self.currentTimeLabel];
    [self.containerView addSubview:self.separateLabel];
    [self.containerView addSubview:self.durationTimeLabel];
    [self.containerView addSubview:self.progressSlider];
    [self.containerView addSubview:self.fullBtn];
    
    [_controlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlMaskView.superview);
    }];

    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.size.offset(49);
        make.bottom.offset(-8);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_playBtn);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel);
        make.leading.equalTo(_playBtn.mas_trailing).offset(0);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playBtn);
        make.leading.equalTo(_currentTimeLabel.mas_trailing);
    }];

    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_separateLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_playBtn.mas_trailing).offset(86 + 8);
        make.height.centerY.equalTo(_playBtn);
        make.trailing.equalTo(_fullBtn.mas_leading).offset(-8);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_playBtn);
        make.centerY.equalTo(_playBtn);
        make.trailing.offset(0);
    }];
    
    
    [CYUIFactory boundaryProtectedWithView:_currentTimeLabel];
    [CYUIFactory boundaryProtectedWithView:_separateLabel];
    [CYUIFactory boundaryProtectedWithView:_durationTimeLabel];
    [CYUIFactory boundaryProtectedWithView:_progressSlider];
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [CYUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_Play];
    [_playBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [CYUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_Pause];
    [_pauseBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    return _pauseBtn;
}

- (CYSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [CYSlider new];
    _progressSlider.tag = CYVideoPlaySliderTag_Progress;
    _progressSlider.enableBufferProgress = YES;
    return _progressSlider;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [CYUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_Full];
    [_fullBtn setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    return _fullBtn;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [CYUILabelFactory labelWithText:@"/" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [CYUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _durationTimeLabel;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [CYUILabelFactory labelWithText:@"00:00" textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:13]];
    return _currentTimeLabel;
}

- (CYVideoPlayerControlMaskView *)controlMaskView {
    if ( _controlMaskView ) return _controlMaskView;
    _controlMaskView = [[CYVideoPlayerControlMaskView alloc] initWithStyle:CYMaskStyle_bottom];
    return _controlMaskView;
}

@end
