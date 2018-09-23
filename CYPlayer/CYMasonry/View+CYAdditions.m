//
//  UIView+CYAdditions.m
//  Cyonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+CYAdditions.h"
#import <objc/runtime.h>

@implementation CY_VIEW (CYAdditions)

- (NSArray *)cy_makeConstraints:(void(^)(CYConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CYConstraintMaker *constraintMaker = [[CYConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)cy_updateConstraints:(void(^)(CYConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CYConstraintMaker *constraintMaker = [[CYConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)cy_remakeConstraints:(void(^)(CYConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CYConstraintMaker *constraintMaker = [[CYConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (CYViewAttribute *)cy_left {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (CYViewAttribute *)cy_top {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (CYViewAttribute *)cy_right {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (CYViewAttribute *)cy_bottom {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (CYViewAttribute *)cy_leading {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (CYViewAttribute *)cy_trailing {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (CYViewAttribute *)cy_width {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (CYViewAttribute *)cy_height {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (CYViewAttribute *)cy_centerX {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (CYViewAttribute *)cy_centerY {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (CYViewAttribute *)cy_baseline {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (CYViewAttribute *(^)(NSLayoutAttribute))cy_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[CYViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CYViewAttribute *)cy_firstBaseline {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (CYViewAttribute *)cy_lastBaseline {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CYViewAttribute *)cy_leftMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (CYViewAttribute *)cy_rightMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (CYViewAttribute *)cy_topMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (CYViewAttribute *)cy_bottomMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (CYViewAttribute *)cy_leadingMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (CYViewAttribute *)cy_trailingMargin {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (CYViewAttribute *)cy_centerXWithinMargins {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (CYViewAttribute *)cy_centerYWithinMargins {
    return [[CYViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (CYViewAttribute *)cy_safeAreaLayoutGuide {
    return [[CYViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CYViewAttribute *)cy_safeAreaLayoutGuideTop {
    return [[CYViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CYViewAttribute *)cy_safeAreaLayoutGuideBottom {
    return [[CYViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CYViewAttribute *)cy_safeAreaLayoutGuideLeft {
    return [[CYViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (CYViewAttribute *)cy_safeAreaLayoutGuideRight {
    return [[CYViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)cy_key {
    return objc_getAssociatedObject(self, @selector(cy_key));
}

- (void)setCy_key:(id)key {
    objc_setAssociatedObject(self, @selector(cy_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)cy_closestCommonSuperview:(CY_VIEW *)view {
    CY_VIEW *closestCommonSuperview = nil;

    CY_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        CY_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
