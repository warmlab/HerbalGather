//
//  FoodMoreViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoodMoreViewController.h"
#import "FoodAboutViewController.h"
#import "FoodUpdateViewController.h"

@implementation FoodMoreViewController
{
	FoodUpdateViewController *updateViewController;
}

@synthesize delegate = _delegate;
@synthesize more_view;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.navigationItem.title = @"更多";
	UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemReply target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = backItem;
	
	updateViewController = [[FoodUpdateViewController alloc] initWithNibName:@"FoodUpdateViewController" bundle:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate moreViewControllerDidFinish:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//if (section == 3)
	//	return @"软件版本";
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [moreList count];
	if (section == 2) {
		return 3;
	}
	
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	//cell.detailTextLabel.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
	switch  (indexPath.section) {
		case 0:
			cell.textLabel.text = @"关于";
			/* 设置cell样式 */
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 1:
			cell.textLabel.text = @"检查是否有新食物";
			/* 设置cell样式 */
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"评价该软件";
					/* 设置cell样式 */
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
					
				case 1:
					cell.textLabel.text = @"给作者写邮件";
					/* 设置cell样式 */
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
					
				case 2:
					cell.textLabel.text = @"访问作者网站";
					/* 设置cell样式 */
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					
				default:
					break;
			}
			break;
		case 3:
			cell.textLabel.text = @"软件版本";
			UILabel *label = [[UILabel  alloc] initWithFrame: CGRectMake(0, 0, 50, 40)];
			[label setBackgroundColor: [UIColor clearColor]];
			label.text = [[[NSBundle mainBundle] infoDictionary ] objectForKey:@"CFBundleVersion"];
			label.textColor = [UIColor darkGrayColor];
			cell.accessoryView= label;
			break;
		case 4:
			cell.textLabel.text = @"更多软件";
			/* 设置cell样式 */
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
			break;
	}

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
			// Navigation logic may go here. Create and push another view controller.
			FoodAboutViewController *aboutViewController = [[FoodAboutViewController alloc] initWithNibName: @"FoodAboutViewController" bundle:nil];
			// ...
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController: aboutViewController animated:YES];
			[aboutViewController release];
	} else if (indexPath.section == 1) {
		// Navigation logic may go here. Create and push another view controller.
		
		// ...
		// Pass the selected object to the new view controller.
		[self.navigationController pushViewController:updateViewController animated:YES];
		//[updateViewController release];
	} else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
#ifdef FOODLITE
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=480654174&mt=8"]];
#else
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=475561576&mt=8"]];
#endif
		} else if (indexPath.row == 1) {
				//NSURL *url = [NSURL URLWithString: @"mailto:warmlab@me.com?subject=食物养生反馈"];
				//[[UIApplication sharedApplication] openURL: url];
			[self displayComposerSheet];
		} else if (indexPath.row ==2) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:  @"http://www.warmlab.com"]];
		}
	} else if (indexPath.section == 4) {
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/cn/artist/xusheng-li/id475561579"]];
		// [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZSearch.woa/wa/viewSoftware?id=475561579"]];
		//http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=limitedAll&restrict=false&submit=seeAllLockups&term=xusheng+li
		// http://itunes.apple.com/cn/artist/xusheng-li/id475561579
		// itms-apps://itunes.com/apps
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"itms-apps://itunes.com/apps/xushengli/"]];
		// @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewArtist?id=292035113";
		
		// @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewArtist?id=292035113";
		
		// @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=292035113";
	}
}

#pragma mark - email
-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"食物养生反馈"];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"warmlab@me.com"];
	
	[picker setMessageBody: nil isHTML:NO];
	[picker setToRecipients: toRecipients];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
