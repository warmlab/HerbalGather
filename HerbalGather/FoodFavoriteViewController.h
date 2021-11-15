//
//  FoodFavoriteViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodFavoriteViewController;

@protocol FoodFavoriteViewControllerDelegate
- (void)favoriteViewControllerDidFinish:(FoodFavoriteViewController *)controller;
@end

@interface FoodFavoriteViewController : UITableViewController;

@property (assign, nonatomic) IBOutlet id <FoodFavoriteViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
