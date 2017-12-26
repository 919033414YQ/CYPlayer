//
//  CYPlayerGestureControl.h
//  CYPlayerGestureControl
//
//  Created by yellowei on 2017/12/10.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CYPanDirection) {
    CYPanDirection_Unknown,
    CYPanDirection_V,
    CYPanDirection_H,
};

typedef NS_ENUM(NSUInteger, CYPanLocation) {
    CYPanLocation_Unknown,
    CYPanLocation_Left,
    CYPanLocation_Right,
};

@interface CYPlayerGestureControl : NSObject

- (instancetype)initWithTargetView:(__weak UIView *)view;

@property (nonatomic, copy, readwrite, nullable) BOOL(^triggerCondition)(CYPlayerGestureControl *control, UIGestureRecognizer *gesture);

@property (nonatomic, copy, readwrite, nullable) void(^singleTapped)(CYPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^doubleTapped)(CYPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^beganPan)(CYPlayerGestureControl *control, CYPanDirection direction, CYPanLocation location);
@property (nonatomic, copy, readwrite, nullable) void(^changedPan)(CYPlayerGestureControl *control, CYPanDirection direction, CYPanLocation location, CGPoint translate);
@property (nonatomic, copy, readwrite, nullable) void(^endedPan)(CYPlayerGestureControl *control, CYPanDirection direction, CYPanLocation location);

@end

NS_ASSUME_NONNULL_END
