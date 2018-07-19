//
//  CYFFmpegPlayer.h
//  CYPlayer
//
//  Created by 黄威 on 2018/7/19.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CYMovieDecoder;

extern NSString * const CYMovieParameterMinBufferedDuration;    // Float
extern NSString * const CYMovieParameterMaxBufferedDuration;    // Float
extern NSString * const CYMovieParameterDisableDeinterlacing;   // BOOL

@interface CYFFmpegPlayer : NSObject

+ (id) movieViewWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;





/*!
 *  present View. support autoLayout.
 *
 *  播放器视图
 */
@property (nonatomic, strong) UIView *view;


@property (readonly) BOOL playing;

- (void) play;
- (void) pause;
- (void) viewDidAppear;
- (void) viewWillDisappear;

@end

