//
//  FoodSettings.m
//  HerbalGather
//
//  Created by 狼 恶 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FoodSettings.h"

@implementation FoodSettings

+ (NSInteger) fontSizeFromSetting {
	NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
	NSInteger fontSize = [setting integerForKey: @"font_size"];
	
	if (fontSize < 18 || fontSize > 20)
		fontSize = 19;
	
	return fontSize;
}

@end
