//
//  CYVideoPlayerTopControlView.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYVideoPlayerTopControlView.h"
#import "CYUIFactory.h"
#import "CYVideoPlayerResources.h"
#import <Masonry/Masonry.h>
#import "CYVideoPlayerControlMaskView.h"

@interface CYVideoPlayerTopControlView ()

@property (nonatomic, strong, readonly) CYVideoPlayerControlMaskView *controlMaskView;

@end

@implementation CYVideoPlayerTopControlView
@synthesize controlMaskView = _controlMaskView;

@synthesize backBtn = _backBtn;
@synthesize previewBtn = _previewBtn;
@synthesize moreBtn = _moreBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _topSetupViews];
    __weak typeof(self) _self = self;
    self.setting = ^(CYVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.backBtn setImage:setting.backBtnImage forState:UIControlStateNormal];
        [self.moreBtn setImage:setting.moreBtnImage forState:UIControlStateNormal];
        if ( setting.previewBtnImage ) {
            [self.previewBtn setImage:setting.previewBtnImage forState:UIControlStateNormal];
        }
        else {
            [self.previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        }
    };
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(topControlView:clickedBtnTag:)] ) return;
    [_delegate topControlView:self clickedBtnTag:btn.tag];
}

- (void)_topSetupViews {
    [self.containerView addSubview:self.controlMaskView];
    [self.containerView addSubview:self.backBtn];
    [self.containerView addSubview:self.previewBtn];
    [self.containerView addSubview:self.moreBtn];
    
    [_controlMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlMaskView.superview);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.size.offset(49);
        make.leading.offset(0);
    }];
    
    [_previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.bottom.equalTo(_backBtn);
        make.trailing.equalTo(_moreBtn.mas_leading).offset(-8);
    }];
    
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.bottom.equalTo(_backBtn);
        make.trailing.offset(-8);
    }];
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [CYUIButtonFactory buttonWithImageName:nil target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_Back];
    return _backBtn;
}

- (UIButton *)previewBtn {
    if ( _previewBtn ) return _previewBtn;
    _previewBtn = [CYUIButtonFactory buttonWithTitle:@"预览" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] backgroundColor:nil target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_Preview];
    return _previewBtn;
}

- (UIButton *)moreBtn {
    if ( _moreBtn ) return _moreBtn;
    _moreBtn = [CYUIButtonFactory buttonWithImageName:[CYVideoPlayerResources bundleComponentWithImageName:@"cy_video_player_more"] target:self sel:@selector(clickedBtn:) tag:CYVideoPlayControlViewTag_More];
    return _moreBtn;
}


- (CYVideoPlayerControlMaskView *)controlMaskView {
    if ( _controlMaskView ) return _controlMaskView;
    _controlMaskView = [[CYVideoPlayerControlMaskView alloc] initWithStyle:CYMaskStyle_top];
    return _controlMaskView;
}

@end
