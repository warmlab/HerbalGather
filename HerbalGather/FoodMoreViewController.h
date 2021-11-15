//
//  FoodMoreViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class FoodMoreViewController;

@protocol FoodMoreViewControllerDelegate
- (void)moreViewControllerDidFinish:(FoodMoreViewController *)controller;
@end

@interface FoodMoreViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
    UITextView *more_view;
}

@property (assign, nonatomic) IBOutlet id <FoodMoreViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *more_view;

- (IBAction)done:(id)sender;
-(void)displayComposerSheet;

@end
