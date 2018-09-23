//
//  CYCompositeConstraint.h
//  Cyonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYConstraint.h"
#import "CYUtilities.h"

/**
 *	A group of CYConstraint objects
 */
@interface CYCompositeConstraint : CYConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child CYConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
