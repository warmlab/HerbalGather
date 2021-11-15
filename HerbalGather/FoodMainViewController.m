//
//  FoodMainViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoodMainViewController.h"
#ifdef FOODLITE
#import "FoodBannerViewContainer.h"
#endif

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@implementation FoodMainViewController
#ifdef FOODLITE
{
	GADBannerView *_bannerView;
	UIViewController<FoodBannerViewContainer> *_currentController;
}

- (void)layoutAnimated:(BOOL)animated
{
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = _bannerView.frame;
    if (!_bannerView.isHidden) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
#ifdef DEBUg
		NSLog(@"x=%lf, y=%lf, w=%lf, h=%lf", bannerFrame.origin.x, bannerFrame.origin.y, bannerFrame.size.width, bannerFrame.size.height);
#endif
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration: 1.0 animations:^{
        //_contentView.frame = contentFrame;
        //[_contentView layoutIfNeeded];
        _bannerView.frame = bannerFrame;
    }];
}
#else
{
	//FoodMoreViewController *moreView;
}
#endif

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef FOODLITE
	CGRect bounds = [[UIScreen mainScreen] bounds];
    _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, bounds.size.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
	// Specify the ad's "unit identifier." This is your AdMob Publisher ID.
	_bannerView.adUnitID = @"a14eefd35937cbe";
	_bannerView.delegate = self;
	_bannerView.hidden = YES;
#endif
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
#ifdef FOODLITE
	_bannerView.rootViewController = self;
	[self.view addSubview:_bannerView];
	[_bannerView loadRequest: [GADRequest request]];
#else
	moreView = [[FoodMoreViewController alloc] initWithNibName:@"FoodMoreViewController" bundle:nil];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
#ifdef FOODLITE
	_bannerView.delegate = nil;
    [_bannerView release];
#else
	[moreView release];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef FOODLITE
	[self layoutAnimated: animated];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation View

- (void)navigationControllerDidFinish:(FoodNavigationController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Search View

- (void)searchViewControllerDidFinish:(FoodSearchViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showAboutInfo:(id)sender
{
	FoodNavigationController *controller = [[[FoodNavigationController alloc] initWithNibName:@"FoodNavigationController" bundle:nil] autorelease];
	controller.moreView = moreView;
    controller.delegate = self;
    controller.kind = 6;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)showFavorite:(id)sender
{
#ifdef FOODLITE
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@"食物养生-Lite版不支持收藏功能，要下载完整版吗？"
								  delegate: self
								  cancelButtonTitle: @"不，以后再说"
								  destructiveButtonTitle: @"好, 去下载"
								  otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
#else
	FoodNavigationController *controller = [[[FoodNavigationController alloc] initWithNibName:@"FoodNavigationController" bundle:nil] autorelease];
    controller.delegate = self;
    controller.kind = 7;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
#endif
}

/*
- (IBAction)showSearcher:(id)sender
{
    FoodSearchViewController *controller = [[[FoodSearchViewController alloc] initWithNibName:@"FoodSearchViewController" bundle:nil] autorelease];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}
*/
- (void) showClassesView: (NSInteger) kind {
    //FoodClassesViewController *controller = [[[FoodClassesViewController alloc] initWithNibName:@"FoodClassesViewController" bundle:nil] autorelease];
    FoodNavigationController *controller = [[[FoodNavigationController alloc] initWithNibName:@"FoodNavigationController" bundle:nil] autorelease];
    controller.delegate = self;
    controller.kind = kind;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)showDisposition:(id)sender {
    [self showClassesView: 0];
}
- (IBAction)showFlavour:(id)sender {
     [self showClassesView: 1];
}
- (IBAction)showMeridian:(id)sender {
     [self showClassesView: 2];
}

- (IBAction)showEfficacy:(id)sender {
#ifdef FOODLITE
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"敬告" message:@"食物养生Lite版不支持此项功能，需要下载完整版吗？" delegate: self cancelButtonTitle:@"以后再说" otherButtonTitles:@"是", nil];
	[alertView show];
#else
	[self showClassesView: 3];
#endif
}

- (IBAction)showDiseases:(id)sender {
#ifdef FOODLITE
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"敬告" message:@"食物养生Lite版不支持此项功能，需要下载完整版吗？" delegate: self cancelButtonTitle:@"以后再说" otherButtonTitles:@"是", nil];
	[alertView show];
#else
	[self showClassesView: 4];
#endif
}

- (IBAction)showSearcher:(id)sender {
    [self showClassesView: 8];
}

#ifdef FOODLITE
-(void) actionSheet : (UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/cn/app/id475561576?mt=8"]];
			break;
		default:
			break;
	}
}

#pragma mar - ADBannerViewDelegate
/*
-(void) bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	if (_currentController == nil) {
		[self layoutAnimated: YES];
	} else
		[_currentController showBannerView:banner animated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"%@", error);
	if (_currentController == nil) {
		[self layoutAnimated: NO];
	} else
		[_currentController hideBannerView:banner animated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
 }
 */

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    _currentController = [viewController respondsToSelector:@selector(showBannerView:animated:)] ? (UIViewController<FoodBannerViewContainer> *)viewController : nil;
    if (_currentController != nil) {
        [(UIViewController<FoodBannerViewContainer> *)viewController showBannerView:_bannerView animated:NO];
    }
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
#ifdef DEBUG
	NSLog(@"Received ad");
#endif
	[adView setHidden: NO];
	if (_currentController) {
		[_currentController showBannerView:adView animated:YES];
	} else
		[self layoutAnimated: YES];
}

- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
#ifdef DEBUG
	NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
#endif
	[adView setHidden: YES];
}

#endif

@end
