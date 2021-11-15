//
//  FoodEfficacyViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodEfficacyViewController;

@protocol FoodEfficacyViewControllerDelegate

- (void)efficacyViewControllerDidFinish:(FoodEfficacyViewController *)controller;

@end

@interface FoodEfficacyViewController : UITableViewController {
	NSInteger kind;
	NSMutableArray *efficacyList;
}

@property (assign, nonatomic) IBOutlet id <FoodEfficacyViewControllerDelegate> delegate;
@property (atomic) NSInteger kind;

@end
