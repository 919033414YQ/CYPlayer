//
//  CYConstraintMaker.h
//  Cyonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYConstraint.h"
#import "CYUtilities.h"

typedef NS_OPTIONS(NSInteger, CYAttribute) {
    CYAttributeLeft = 1 << NSLayoutAttributeLeft,
    CYAttributeRight = 1 << NSLayoutAttributeRight,
    CYAttributeTop = 1 << NSLayoutAttributeTop,
    CYAttributeBottom = 1 << NSLayoutAttributeBottom,
    CYAttributeLeading = 1 << NSLayoutAttributeLeading,
    CYAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    CYAttributeWidth = 1 << NSLayoutAttributeWidth,
    CYAttributeHeight = 1 << NSLayoutAttributeHeight,
    CYAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    CYAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    CYAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    CYAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    CYAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    CYAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    CYAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    CYAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    CYAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    CYAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    CYAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    CYAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    CYAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating CYConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface CYConstraintMaker : NSObject

/**
 *	The following properties return a new CYViewConstraint
 *  with the first item set to the makers associated view and the appropriate CYViewAttribute
 */
@property (nonatomic, strong, readonly) CYConstraint *left;
@property (nonatomic, strong, readonly) CYConstraint *top;
@property (nonatomic, strong, readonly) CYConstraint *right;
@property (nonatomic, strong, readonly) CYConstraint *bottom;
@property (nonatomic, strong, readonly) CYConstraint *leading;
@property (nonatomic, strong, readonly) CYConstraint *trailing;
@property (nonatomic, strong, readonly) CYConstraint *width;
@property (nonatomic, strong, readonly) CYConstraint *height;
@property (nonatomic, strong, readonly) CYConstraint *centerX;
@property (nonatomic, strong, readonly) CYConstraint *centerY;
@property (nonatomic, strong, readonly) CYConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CYConstraint *firstBaseline;
@property (nonatomic, strong, readonly) CYConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CYConstraint *leftMargin;
@property (nonatomic, strong, readonly) CYConstraint *rightMargin;
@property (nonatomic, strong, readonly) CYConstraint *topMargin;
@property (nonatomic, strong, readonly) CYConstraint *bottomMargin;
@property (nonatomic, strong, readonly) CYConstraint *leadingMargin;
@property (nonatomic, strong, readonly) CYConstraint *trailingMargin;
@property (nonatomic, strong, readonly) CYConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) CYConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new CYCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  CYAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) CYConstraint *(^attributes)(CYAttribute attrs);

/**
 *	Creates a CYCompositeConstraint with type CYCompositeConstraintTypeEdges
 *  which generates the appropriate CYViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CYConstraint *edges;

/**
 *	Creates a CYCompositeConstraint with type CYCompositeConstraintTypeSize
 *  which generates the appropriate CYViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CYConstraint *size;

/**
 *	Creates a CYCompositeConstraint with type CYCompositeConstraintTypeCenter
 *  which generates the appropriate CYViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) CYConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any CYConstraint are created with this view as the first item
 *
 *	@return	a new CYConstraintMaker
 */
- (id)initWithView:(CY_VIEW *)view;

/**
 *	Calls install method on any CYConstraints which have been created by this maker
 *
 *	@return	an array of all the installed CYConstraints
 */
- (NSArray *)install;

- (CYConstraint * (^)(dispatch_block_t))group;

@end
