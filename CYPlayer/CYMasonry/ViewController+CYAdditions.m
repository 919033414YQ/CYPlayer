//
//  UIViewController+CYAdditions.m
//  Cyonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+CYAdditions.h"

#ifdef CY_VIEW_CONTROLLER

@implementation CY_VIEW_CONTROLLER (CYAdditions)

- (CYViewAttribute *)cy_topLayoutGuide {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (CYViewAttribute *)cy_topLayoutGuideTop {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CYViewAttribute *)cy_topLayoutGuideBottom {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (CYViewAttribute *)cy_bottomLayoutGuide {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CYViewAttribute *)cy_bottomLayoutGuideTop {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (CYViewAttribute *)cy_bottomLayoutGuideBottom {
    return [[CYViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
