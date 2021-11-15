//
//  FoodNavigationController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoodNavigationController.h"

//#define BACKGROUND_COLOR [UIColor colorWithRed: (CGFloat)0x4f/256 green: (CGFloat)0x99/256 blue: (CGFloat)0xf3/256 alpha: (CGFloat)1]
#define BACKGROUND_COLOR [UIColor colorWithRed: (CGFloat)47/256 green: (CGFloat)120/256 blue: (CGFloat)238/256 alpha: (CGFloat)1]

@implementation FoodNavigationController

@synthesize kind;
@synthesize delegate;
@synthesize moreView;

-(void) viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.tintColor = BACKGROUND_COLOR;
    
    if (kind == 8) {
        FoodSearchViewController *theView = [[[FoodSearchViewController alloc] initWithNibName:@"FoodSearchViewController" bundle:nil] autorelease];
        theView.delegate = self;
        rootView = theView;
    } else if (kind == 7) {
#ifndef FOODLITE
        FoodFavoriteViewController *theView = [[[FoodFavoriteViewController alloc] initWithNibName:@"FoodFavoriteViewController" bundle:nil] autorelease];
        theView.delegate = self;
        rootView = theView;
#endif
    } else if (kind == 6) {
        moreView.delegate = self;
        rootView = moreView;
    } else {
		FoodClassesViewController *theView = [[[FoodClassesViewController alloc] initWithNibName:@"FoodClassesViewController" bundle:nil] autorelease];
		theView.kind = kind;
		theView.delegate = self;
        rootView = theView;
    }
    [self pushViewController: rootView animated: NO];
}

-(void) viewDidUnload {
    [rootView release];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

#pragma mark - Classes View
- (void)classesViewControllerDidFinish:(FoodClassesViewController *)controller
{
    [self popViewControllerAnimated: NO];
    [self.delegate navigationControllerDidFinish:self];
}

#pragma mark - Search View
- (void)searchViewControllerDidFinish:(FoodSearchViewController *)controller
{
    [self popViewControllerAnimated: NO];
    [self.delegate navigationControllerDidFinish:self];
}

#pragma mark - About View

- (void)moreViewControllerDidFinish:(FoodMoreViewController *)controller
{
    [self popViewControllerAnimated: NO];
    [self.delegate navigationControllerDidFinish:self];
}

#ifndef FOODLITE
#pragma mark - Efficacy View
-(void)efficacyViewControllerDidFinish:(FoodEfficacyViewController *)controller
{
    [self popViewControllerAnimated: NO];
    [self.delegate navigationControllerDidFinish:self];
}

#pragma mark - Favorite View
-(void)favoriteViewControllerDidFinish:(FoodFavoriteViewController *)controller
{
    [self popViewControllerAnimated: NO];
    [self.delegate navigationControllerDidFinish:self];
}
#endif

@end
