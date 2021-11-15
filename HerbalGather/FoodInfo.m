//
//  FoodInfo.m
//  Foods
//
//  Created by 恶狼 on 10-12-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FoodInfo.h"

@implementation FoodInfo
@synthesize foodId, yike;
@synthesize foodName;

-(void) setUTF8Value:(char *) val {
	[foodName release];
	foodName = [[NSString alloc] initWithUTF8String: val];
}

@end
