//
//  CYConstraint+Private.h
//  Cyonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "CYConstraint.h"

@protocol CYConstraintDelegate;


@interface CYConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually CYConstraintMaker but could be a parent CYConstraint
 */
@property (nonatomic, weak) id<CYConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with CYEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface CYConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    CYViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (CYConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (CYConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol CYConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A CYViewConstraint may turn into a CYCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(CYConstraint *)constraint shouldBeReplacedWithConstraint:(CYConstraint *)replacementConstraint;

- (CYConstraint *)constraint:(CYConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
