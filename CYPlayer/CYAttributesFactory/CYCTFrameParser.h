//
//  CYCTFrameParser.h
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYCTData, CYCTFrameParserConfig;

@interface CYCTFrameParser : NSObject

+ (CYCTData *)parserContent:(NSString *)content config:(CYCTFrameParserConfig *)config;

+ (CYCTData *)parserAttributedStr:(NSAttributedString *)content config:(CYCTFrameParserConfig *)config;

@end
