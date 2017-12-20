//
//  CYButtonSlider.h
//  CYSlider
//
//  Created by BlueDancer on 2017/11/20.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYCommonSlider.h"

@interface CYButtonSlider : CYCommonSlider

@property (nonatomic, strong, readonly) UIButton *leftBtn;
@property (nonatomic, strong, readonly) UIButton *rightBtn;

@property (nonatomic, strong, readwrite) NSString *leftText;
@property (nonatomic, strong, readwrite) NSString *rightText;

@property (nonatomic, strong, readwrite) UIColor *titleColor;

@end
