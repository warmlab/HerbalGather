//
//  FoodSummaryViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodSummaryViewController : UITableViewController <UIActionSheetDelegate>{
    NSInteger   foodId;
	BOOL		toChange;
}

@property (assign, atomic) NSInteger foodId;
@property (assign, atomic) BOOL toChange;

@end
