//
//  CYVideoPlayerAssetCarrier.h
//  CYVideoPlayerProject
//
//  Created by yellowei on 2017/9/1.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYVideoPreviewModel;

@interface CYVideoPlayerAssetCarrier : NSObject

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime;

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag; // video player parent `view tag`

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag;

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView;

#pragma mark - screenshot
- (UIImage * __nullable)screenshot;

- (UIImage *)randomScreenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(CYVideoPlayerAssetCarrier *asset, CYVideoPreviewModel * __nullable images, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(CYVideoPlayerAssetCarrier *asset, CYVideoPreviewModel * __nullable images, NSError *__nullable error))block;


#pragma mark - player status
@property (nonatomic, copy, readwrite, nullable) void(^playerItemStateChanged)(CYVideoPlayerAssetCarrier *asset, AVPlayerItemStatus status);

@property (nonatomic, copy, readwrite, nullable) void(^playTimeChanged)(CYVideoPlayerAssetCarrier *asset, NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(CYVideoPlayerAssetCarrier *asset);
/// 缓冲进度回调
@property (nonatomic, copy, readwrite, nullable) void(^loadedTimeProgress)(float progress);
/// 缓冲已为空, 开始缓冲
@property (nonatomic, copy, readwrite, nullable) void(^beingBuffered)(BOOL state);


#pragma mark - scroll view
@property (nonatomic, copy, readwrite, nullable) void(^touchedScrollView)(CYVideoPlayerAssetCarrier *asset, BOOL tracking);

@property (nonatomic, copy, readwrite, nullable) void(^scrollViewDidScroll)(CYVideoPlayerAssetCarrier *asset);

@property (nonatomic, copy, readwrite, nullable) void(^presentationSize)(CYVideoPlayerAssetCarrier *asset, CGSize size);

@property (nonatomic, copy, readwrite, nullable) void(^scrollIn)(CYVideoPlayerAssetCarrier *asset, UIView *superView);

@property (nonatomic, copy, readwrite, nullable) void(^scrollOut)(CYVideoPlayerAssetCarrier *asset);


#pragma mark - preview images
@property (nonatomic, assign, readonly) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readonly) NSArray<CYVideoPreviewModel *> *generatedPreviewImages;
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(CYVideoPlayerAssetCarrier *asset, NSArray<CYVideoPreviewModel *> *__nullable images, NSError *__nullable error))block;
- (void)cancelPreviewImagesGeneration;


#pragma mark - seek to time
- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;


#pragma mark - properties
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, assign, readonly) NSTimeInterval beginTime; // unit is sec.
@property (nonatomic, assign, readonly) NSTimeInterval duration; // unit is sec.
@property (nonatomic, assign, readonly) NSTimeInterval currentTime; // unit is sec.
@property (nonatomic, assign, readonly) float progress; // 0..1
@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) NSInteger superviewTag;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSInteger scrollViewTag; // _scrollView `tag`
@property (nonatomic, strong, readonly, nullable) NSIndexPath *scrollViewIndexPath;
@property (nonatomic, unsafe_unretained, readonly, nullable) UIScrollView *rootScrollView;

@end


#pragma mark - preview model
@interface CYVideoPreviewModel : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time;

@end

NS_ASSUME_NONNULL_END


