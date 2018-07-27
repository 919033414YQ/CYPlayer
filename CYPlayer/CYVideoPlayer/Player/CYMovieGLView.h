//
//  ESGLView.h
//  kxmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of CYMovie
//  CYMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class CYVideoFrame;
@class CYMovieDecoder;

@interface CYMovieGLView : UIView

- (id) initWithFrame:(CGRect)frame
             decoder: (CYMovieDecoder *) decoder;

- (void) render: (CYVideoFrame *) frame;

@end
