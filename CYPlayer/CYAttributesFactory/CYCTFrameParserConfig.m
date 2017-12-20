//
//  CYCTFrameParserConfig.m
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "CYCTFrameParserConfig.h"

@implementation CYCTFrameParserConfig

+ (CGFloat)fontSize:(UIFont *)font {
    return [[font.fontDescriptor objectForKey:UIFontDescriptorSizeAttribute] doubleValue];
}

@end
