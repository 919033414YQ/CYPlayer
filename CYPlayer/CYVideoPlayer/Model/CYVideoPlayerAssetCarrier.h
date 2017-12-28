//
//  CYVideoPlayerAssetCarrier.h
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/9/1.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CYVideoPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const CY_AVPlayerRateDidChangeNotification;

@interface CYVideoPlayerAssetCarrier : NSObject

- (UIImage * __nullable)screenshot;

- (UIImage *__nullable)randomScreenshot;

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime;

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(__weak NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag;

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(__weak NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag;

@property (nonatomic, copy, readwrite, nullable) void(^playerItemStateChanged)(CYVideoPlayerAssetCarrier *asset, AVPlayerItemStatus status);

@property (nonatomic, copy, readwrite, nullable) void(^playTimeChanged)(CYVideoPlayerAssetCarrier *asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(CYVideoPlayerAssetCarrier *asset);

@property (nonatomic, copy, readwrite, nullable) void(^loadedTimeProgress)(float progress);

@property (nonatomic, copy, readwrite, nullable) void(^beingBuffered)(BOOL state);

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void(^)(CYVideoPlayerAssetCarrier *asset, NSArray<CYVideoPreviewModel *> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;
- (void)screenshotWithTime:(NSTimeInterval)time size:(CGSize)size completion:(void(^)(CYVideoPlayerAssetCarrier *asset, CYVideoPreviewModel *images, NSError *__nullable error))block ;

@property (nonatomic, copy, readwrite, nullable) void(^deallocCallBlock)(CYVideoPlayerAssetCarrier *asset);

@property (nonatomic, copy, readwrite, nullable) void(^scrollViewDidScroll)(CYVideoPlayerAssetCarrier *asset);


@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, assign, readonly) NSTimeInterval beginTime;
@property (nonatomic, assign, readwrite) BOOL jumped;
@property (nonatomic, assign, readonly) NSTimeInterval duration; // unit is sec.
@property (nonatomic, assign, readonly) NSTimeInterval currentTime; // unit is sec.
@property (nonatomic, assign, readonly) float progress; // 0..1
@property (nonatomic, assign, readonly) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) NSArray<CYVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, weak, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) NSInteger superviewTag;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *scrollView;

@end

NS_ASSUME_NONNULL_END
