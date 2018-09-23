//
//  NSArray+CYAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+CYAdditions.h"
#import "View+CYAdditions.h"

@implementation NSArray (CYAdditions)

- (NSArray *)cy_makeConstraints:(void(^)(CYConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CY_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CY_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view cy_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)cy_updateConstraints:(void(^)(CYConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CY_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CY_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view cy_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)cy_remakeConstraints:(void(^)(CYConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (CY_VIEW *view in self) {
        NSAssert([view isKindOfClass:[CY_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view cy_remakeConstraints:block]];
    }
    return constraints;
}

- (void)cy_distributeViewsAlongAxis:(CYAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    CY_VIEW *tempSuperView = [self cy_commonSuperviewOfViews];
    if (axisType == CYAxisTypeHorizontal) {
        CY_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CY_VIEW *v = self[i];
            [v cy_makeConstraints:^(CYConstraintMaker *make) {
                if (prev) {
                    make.width.equalTo(prev);
                    make.left.equalTo(prev.cy_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
    else {
        CY_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CY_VIEW *v = self[i];
            [v cy_makeConstraints:^(CYConstraintMaker *make) {
                if (prev) {
                    make.height.equalTo(prev);
                    make.top.equalTo(prev.cy_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }                    
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
}

- (void)cy_distributeViewsAlongAxis:(CYAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    CY_VIEW *tempSuperView = [self cy_commonSuperviewOfViews];
    if (axisType == CYAxisTypeHorizontal) {
        CY_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CY_VIEW *v = self[i];
            [v cy_makeConstraints:^(CYConstraintMaker *make) {
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.right.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
    else {
        CY_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            CY_VIEW *v = self[i];
            [v cy_makeConstraints:^(CYConstraintMaker *make) {
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.bottom.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (CY_VIEW *)cy_commonSuperviewOfViews
{
    CY_VIEW *commonSuperview = nil;
    CY_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[CY_VIEW class]]) {
            CY_VIEW *view = (CY_VIEW *)object;
            if (previousView) {
                commonSuperview = [view cy_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end
