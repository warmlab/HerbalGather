//
//  FoodInfo.h
//  Foods
//
//  Created by 恶狼 on 10-12-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodInfo : NSObject {
	NSInteger	foodId;
	NSString	*foodName;
    NSInteger   yike;
}

@property (assign, atomic) NSInteger foodId, yike;
@property (nonatomic, retain) NSString *foodName;

-(void) setUTF8Value:(char *)val;
@end
