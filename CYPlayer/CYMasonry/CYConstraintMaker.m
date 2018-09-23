//
//  CYConstraintMaker.m
//  Cyonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CYConstraintMaker.h"
#import "CYViewConstraint.h"
#import "CYCompositeConstraint.h"
#import "CYConstraint+Private.h"
#import "CYViewAttribute.h"
#import "View+CYAdditions.h"

@interface CYConstraintMaker () <CYConstraintDelegate>

@property (nonatomic, weak) CY_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation CYConstraintMaker

- (id)initWithView:(CY_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [CYViewConstraint installedConstraintsForView:self.view];
        for (CYConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (CYConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - CYConstraintDelegate

- (void)constraint:(CYConstraint *)constraint shouldBeReplacedWithConstraint:(CYConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (CYConstraint *)constraint:(CYConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    CYViewAttribute *viewAttribute = [[CYViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    CYViewConstraint *newConstraint = [[CYViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:CYViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        CYCompositeConstraint *compositeConstraint = [[CYCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (CYConstraint *)addConstraintWithAttributes:(CYAttribute)attrs {
    __unused CYAttribute anyAttribute = (CYAttributeLeft | CYAttributeRight | CYAttributeTop | CYAttributeBottom | CYAttributeLeading
                                          | CYAttributeTrailing | CYAttributeWidth | CYAttributeHeight | CYAttributeCenterX
                                          | CYAttributeCenterY | CYAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | CYAttributeFirstBaseline | CYAttributeLastBaseline
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
                                          | CYAttributeLeftMargin | CYAttributeRightMargin | CYAttributeTopMargin | CYAttributeBottomMargin
                                          | CYAttributeLeadingMargin | CYAttributeTrailingMargin | CYAttributeCenterXWithinMargins
                                          | CYAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & CYAttributeLeft) [attributes addObject:self.view.cy_left];
    if (attrs & CYAttributeRight) [attributes addObject:self.view.cy_right];
    if (attrs & CYAttributeTop) [attributes addObject:self.view.cy_top];
    if (attrs & CYAttributeBottom) [attributes addObject:self.view.cy_bottom];
    if (attrs & CYAttributeLeading) [attributes addObject:self.view.cy_leading];
    if (attrs & CYAttributeTrailing) [attributes addObject:self.view.cy_trailing];
    if (attrs & CYAttributeWidth) [attributes addObject:self.view.cy_width];
    if (attrs & CYAttributeHeight) [attributes addObject:self.view.cy_height];
    if (attrs & CYAttributeCenterX) [attributes addObject:self.view.cy_centerX];
    if (attrs & CYAttributeCenterY) [attributes addObject:self.view.cy_centerY];
    if (attrs & CYAttributeBaseline) [attributes addObject:self.view.cy_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & CYAttributeFirstBaseline) [attributes addObject:self.view.cy_firstBaseline];
    if (attrs & CYAttributeLastBaseline) [attributes addObject:self.view.cy_lastBaseline];
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    if (attrs & CYAttributeLeftMargin) [attributes addObject:self.view.cy_leftMargin];
    if (attrs & CYAttributeRightMargin) [attributes addObject:self.view.cy_rightMargin];
    if (attrs & CYAttributeTopMargin) [attributes addObject:self.view.cy_topMargin];
    if (attrs & CYAttributeBottomMargin) [attributes addObject:self.view.cy_bottomMargin];
    if (attrs & CYAttributeLeadingMargin) [attributes addObject:self.view.cy_leadingMargin];
    if (attrs & CYAttributeTrailingMargin) [attributes addObject:self.view.cy_trailingMargin];
    if (attrs & CYAttributeCenterXWithinMargins) [attributes addObject:self.view.cy_centerXWithinMargins];
    if (attrs & CYAttributeCenterYWithinMargins) [attributes addObject:self.view.cy_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (CYViewAttribute *a in attributes) {
        [children addObject:[[CYViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    CYCompositeConstraint *constraint = [[CYCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (CYConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

- (CYConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (CYConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (CYConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (CYConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (CYConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (CYConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (CYConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (CYConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (CYConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (CYConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (CYConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (CYConstraint *(^)(CYAttribute))attributes {
    return ^(CYAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (CYConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (CYConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif


#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (CYConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (CYConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (CYConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (CYConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (CYConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (CYConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (CYConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (CYConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (CYConstraint *)edges {
    return [self addConstraintWithAttributes:CYAttributeTop | CYAttributeLeft | CYAttributeRight | CYAttributeBottom];
}

- (CYConstraint *)size {
    return [self addConstraintWithAttributes:CYAttributeWidth | CYAttributeHeight];
}

- (CYConstraint *)center {
    return [self addConstraintWithAttributes:CYAttributeCenterX | CYAttributeCenterY];
}

#pragma mark - grouping

- (CYConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        CYCompositeConstraint *constraint = [[CYCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
