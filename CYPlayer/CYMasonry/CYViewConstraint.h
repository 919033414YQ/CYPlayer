//
//  CYViewConstraint.h
//  Cyonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYViewAttribute.h"
#import "CYConstraint.h"
#import "CYLayoutConstraint.h"
#import "CYUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface CYViewConstraint : CYConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CYViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) CYViewAttribute *secondViewAttribute;

/**
 *	initialises the CYViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.cy_left, view.cy_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(CYViewAttribute *)firstViewAttribute;

/**
 *  Returns all CYViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of CYViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(CY_VIEW *)view;

@end
