//
//  UIViewController+CYAdditions.h
//  Cyonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "CYUtilities.h"
#import "CYConstraintMaker.h"
#import "CYViewAttribute.h"

#ifdef CY_VIEW_CONTROLLER

@interface CY_VIEW_CONTROLLER (CYAdditions)

/**
 *	following properties return a new CYViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) CYViewAttribute *cy_topLayoutGuide;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_bottomLayoutGuide;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_topLayoutGuideTop;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) CYViewAttribute *cy_bottomLayoutGuideBottom;


@end

#endif
