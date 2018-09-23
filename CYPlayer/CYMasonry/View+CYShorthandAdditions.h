//
//  UIView+CYShorthandAdditions.h
//  Cyonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+CYAdditions.h"

#ifdef CY_SHORTHAND

/**
 *	Shorthand view additions without the 'cy_' prefixes,
 *  only enabled if CY_SHORTHAND is defined
 */
@interface CY_VIEW (CYShorthandAdditions)

@property (nonatomic, strong, readonly) CYViewAttribute *left;
@property (nonatomic, strong, readonly) CYViewAttribute *top;
@property (nonatomic, strong, readonly) CYViewAttribute *right;
@property (nonatomic, strong, readonly) CYViewAttribute *bottom;
@property (nonatomic, strong, readonly) CYViewAttribute *leading;
@property (nonatomic, strong, readonly) CYViewAttribute *trailing;
@property (nonatomic, strong, readonly) CYViewAttribute *width;
@property (nonatomic, strong, readonly) CYViewAttribute *height;
@property (nonatomic, strong, readonly) CYViewAttribute *centerX;
@property (nonatomic, strong, readonly) CYViewAttribute *centerY;
@property (nonatomic, strong, readonly) CYViewAttribute *baseline;
@property (nonatomic, strong, readonly) CYViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CYViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) CYViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CYViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *topMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) CYViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CYViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(CYConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CYConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CYConstraintMaker *make))block;

@end

#define CY_ATTR_FORWARD(attr)  \
- (CYViewAttribute *)attr {    \
    return [self cy_##attr];   \
}

@implementation CY_VIEW (CYShorthandAdditions)

CY_ATTR_FORWARD(top);
CY_ATTR_FORWARD(left);
CY_ATTR_FORWARD(bottom);
CY_ATTR_FORWARD(right);
CY_ATTR_FORWARD(leading);
CY_ATTR_FORWARD(trailing);
CY_ATTR_FORWARD(width);
CY_ATTR_FORWARD(height);
CY_ATTR_FORWARD(centerX);
CY_ATTR_FORWARD(centerY);
CY_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

CY_ATTR_FORWARD(firstBaseline);
CY_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

CY_ATTR_FORWARD(leftMargin);
CY_ATTR_FORWARD(rightMargin);
CY_ATTR_FORWARD(topMargin);
CY_ATTR_FORWARD(bottomMargin);
CY_ATTR_FORWARD(leadingMargin);
CY_ATTR_FORWARD(trailingMargin);
CY_ATTR_FORWARD(centerXWithinMargins);
CY_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

CY_ATTR_FORWARD(safeAreaLayoutGuideTop);
CY_ATTR_FORWARD(safeAreaLayoutGuideBottom);
CY_ATTR_FORWARD(safeAreaLayoutGuideLeft);
CY_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (CYViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self cy_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *))block {
    return [self cy_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *))block {
    return [self cy_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *))block {
    return [self cy_remakeConstraints:block];
}

@end

#endif
