//
//  CYCommonSlider.h
//  CYSlider
//
//  Created by BlueDancer on 2017/11/20.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYSlider.h"

@interface CYCommonSlider : UIView

@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) CYSlider *slider;
@property (nonatomic, strong, readonly) UIView *rightContainerView;

@end
