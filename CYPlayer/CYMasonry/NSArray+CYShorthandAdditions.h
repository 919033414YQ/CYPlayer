//
//  NSArray+CYShorthandAdditions.h
//  Cyonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+CYAdditions.h"

#ifdef CY_SHORTHAND

/**
 *	Shorthand array additions without the 'cy_' prefixes,
 *  only enabled if CY_SHORTHAND is defined
 */
@interface NSArray (CYShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CYConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(CYConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(CYConstraintMaker *make))block;

@end

@implementation NSArray (CYShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(CYConstraintMaker *))block {
    return [self cy_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(CYConstraintMaker *))block {
    return [self cy_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(CYConstraintMaker *))block {
    return [self cy_remakeConstraints:block];
}

@end

#endif
