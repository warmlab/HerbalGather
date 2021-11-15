//
//  FoodSearchViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodSearchViewController;

@protocol FoodSearchViewControllerDelegate
- (void)searchViewControllerDidFinish:(FoodSearchViewController *)controller;
@end

@interface FoodSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate> {
	NSMutableArray *foodList;
}

@property (assign, nonatomic) IBOutlet id <FoodSearchViewControllerDelegate> delegate;

@end
