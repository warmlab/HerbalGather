//
//  FoodClassesViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodClassesViewController;

@protocol FoodClassesViewControllerDelegate
- (void)classesViewControllerDidFinish:(FoodClassesViewController *)controller;
@end

//@interface FoodClassesViewController : UIViewController<UITableViewDelegate> {
@interface FoodClassesViewController : UITableViewController {
    NSInteger kind;
    NSMutableArray *kind_array;
}

@property (assign, nonatomic) IBOutlet id <FoodClassesViewControllerDelegate> delegate;
@property (atomic) NSInteger kind;

- (IBAction)done:(id)sender;

@end


