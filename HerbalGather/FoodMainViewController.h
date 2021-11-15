//
//  FoodMainViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#ifdef FOODLITE
#import "GADBannerView.h"
#endif
//#import "FoodClassesViewController.h"
#import "FoodNavigationController.h"
//#import "FoodSearchViewController.h"
#import "FoodMoreViewController.h"

@interface FoodMainViewController : UIViewController <FoodNavigationControllerDelegate
#ifdef FOODLITE
, GADBannerViewDelegate, UIActionSheetDelegate
#endif
>
#ifdef FOODLITE
{
    //ADBannerView *adView;
}
#else
{
FoodMoreViewController *moreView;
}
#endif

- (IBAction)showAboutInfo:(id)sender;
- (IBAction)showDisposition:(id)sender;
- (IBAction)showFlavour:(id)sender;
- (IBAction)showMeridian:(id)sender;
- (IBAction)showSearcher:(id)sender;
- (IBAction)showFavorite:(id)sender;

@end
