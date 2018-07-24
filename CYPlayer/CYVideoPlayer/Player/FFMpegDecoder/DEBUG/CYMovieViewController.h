//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of CYMovie
//  CYMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class CYMovieDecoder;

extern NSString * const CYMovieParameterMinBufferedDuration;    // Float
extern NSString * const CYMovieParameterMaxBufferedDuration;    // Float
extern NSString * const CYMovieParameterDisableDeinterlacing;   // BOOL

@interface CYMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (readonly) BOOL playing;

- (void) play;
- (void) pause;

@end
