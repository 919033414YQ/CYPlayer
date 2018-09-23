//
//  CYConstraint.h
//  Cyonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (CYViewConstraint) 
 *  or a group of NSLayoutConstraints (CYComposisteConstraint)
 */
@interface CYConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (CYConstraint * (^)(CYEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (CYConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (CYConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (CYConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (CYConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (CYConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (CYConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (CYConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or CYLayoutPriority
 */
- (CYConstraint * (^)(CYLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to CYLayoutPriorityLow
 */
- (CYConstraint * (^)(void))priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to CYLayoutPriorityMedium
 */
- (CYConstraint * (^)(void))priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to CYLayoutPriorityHigh
 */
- (CYConstraint * (^)(void))priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    CYViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CYConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    CYViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CYConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    CYViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CYConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (CYConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (CYConstraint *)and;

/**
 *	Creates a new CYCompositeConstraint with the called attribute and reciever
 */
- (CYConstraint *)left;
- (CYConstraint *)top;
- (CYConstraint *)right;
- (CYConstraint *)bottom;
- (CYConstraint *)leading;
- (CYConstraint *)trailing;
- (CYConstraint *)width;
- (CYConstraint *)height;
- (CYConstraint *)centerX;
- (CYConstraint *)centerY;
- (CYConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CYConstraint *)firstBaseline;
- (CYConstraint *)lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CYConstraint *)leftMargin;
- (CYConstraint *)rightMargin;
- (CYConstraint *)topMargin;
- (CYConstraint *)bottomMargin;
- (CYConstraint *)leadingMargin;
- (CYConstraint *)trailingMargin;
- (CYConstraint *)centerXWithinMargins;
- (CYConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (CYConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of cy_updateConstraints/cy_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(CYEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects CYConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) CYConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end


/**
 *  Convenience auto-boxing macros for CYConstraint methods.
 *
 *  Defining CY_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define cy_equalTo(...)                 equalTo(CYBoxValue((__VA_ARGS__)))
#define cy_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(CYBoxValue((__VA_ARGS__)))
#define cy_lessThanOrEqualTo(...)       lessThanOrEqualTo(CYBoxValue((__VA_ARGS__)))

#define cy_offset(...)                  valueOffset(CYBoxValue((__VA_ARGS__)))


#ifdef CY_SHORTHAND_GLOBALS

#define equalTo(...)                     cy_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...)        cy_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...)           cy_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...)                      cy_offset(__VA_ARGS__)

#endif


@interface CYConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (CYConstraint * (^)(id attr))cy_equalTo;
- (CYConstraint * (^)(id attr))cy_greaterThanOrEqualTo;
- (CYConstraint * (^)(id attr))cy_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (CYConstraint * (^)(id offset))cy_offset;

@end
