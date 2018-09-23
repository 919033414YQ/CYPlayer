//
//  UIView+CYAdditions.h
//  Cyonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYUtilities.h"
#import "CYConstraintMaker.h"
#import "CYViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating CYViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface CY_VIEW (CYAdditions)

/**
 *	following properties return a new CYViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CYViewAttribute *cy_left;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_top;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_right;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_bottom;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_leading;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_trailing;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_width;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_height;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_centerX;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_centerY;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_baseline;
@property (nonatomic, strong, readonly) CYViewAttribute *(^cy_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) CYViewAttribute *cy_firstBaseline;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) CYViewAttribute *cy_leftMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_rightMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_topMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_bottomMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_leadingMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_trailingMargin;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_centerXWithinMargins;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) CYViewAttribute *cy_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *cy_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *cy_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *cy_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) CYViewAttribute *cy_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id cy_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)cy_closestCommonSuperview:(CY_VIEW *)view;

/**
 *  Creates a CYConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created CYConstraints
 */
- (NSArray *)cy_makeConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *make))block;

/**
 *  Creates a CYConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CYConstraints
 */
- (NSArray *)cy_updateConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *make))block;

/**
 *  Creates a CYConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated CYConstraints
 */
- (NSArray *)cy_remakeConstraints:(void(NS_NOESCAPE ^)(CYConstraintMaker *make))block;

@end
