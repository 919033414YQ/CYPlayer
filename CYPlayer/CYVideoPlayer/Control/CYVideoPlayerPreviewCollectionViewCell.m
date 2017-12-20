//
//  CYVideoPlayerPreviewCollectionViewCell.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYVideoPlayerPreviewCollectionViewCell.h"
#import "CYUIFactory.h"
#import "CYVideoPlayerResources.h"
#import <Masonry/Masonry.h>

@interface CYVideoPlayerPreviewCollectionViewCell ()

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@implementation CYVideoPlayerPreviewCollectionViewCell

@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _collectionSetupView];
    return self;
}

- (void)setModel:(CYVideoPreviewModel *)model {
    _model = model;
    _imageView.image = model.image;
}

- (void)_collectionSetupView {
    [self.contentView addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_imageView.superview);
    }];
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [CYUIImageViewFactory imageViewWithImageName:@"" viewMode:UIViewContentModeScaleAspectFill];
    return _imageView;
}
@end
