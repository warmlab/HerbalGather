//
//  FoodNavigationController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodMoreViewController.h"
#import "FoodClassesViewController.h"
#import "FoodSearchViewController.h"
#ifndef FOODLITE
#import "FoodFavoriteViewController.h"
#import "FoodEfficacyViewController.h"
#endif

@class FoodNavigationController;

@protocol FoodNavigationControllerDelegate <UINavigationControllerDelegate>
- (void) navigationControllerDidFinish:(FoodNavigationController *)controller;
@end

@interface FoodNavigationController : UINavigationController <FoodClassesViewControllerDelegate, FoodSearchViewControllerDelegate, FoodMoreViewControllerDelegate
#ifndef FOODLITE
, FoodEfficacyViewControllerDelegate, FoodFavoriteViewControllerDelegate
#endif
> {
    NSInteger kind;
    id rootView;
}

@property (assign, nonatomic) IBOutlet id <FoodNavigationControllerDelegate> delegate;
@property (assign, nonatomic) FoodMoreViewController *moreView;
@property (atomic) NSInteger kind;

@end
