//
//  FoodCounteractViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "FoodCounteractViewController.h"
#import "encrypt.h"
#import "FoodSummaryViewController.h"
#import "FoodSettings.h"

#import "WLCrypto.h"

extern char *path;

@implementation FoodCounteractViewController {
	NSString *foodName1;
	NSString *foodName2;
	NSString *content;
	NSInteger counteract;
	NSInteger fontSize;
}

@synthesize foodId1, foodId2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	sqlite3 *db;
	if (sqlite3_open(path, &db)) {
		sqlite3_close(db);
		return;
	}
	
	char *format = "select f1.name, f2.name, r.relation, r.nature \
	from foods_relation r, foods_food f1, foods_food f2 \
	where f1.id=%d and f2.id=%d and ((r.food1_id=%d and r.food2_id = %d) or \
	(r.food2_id=%d and r.food1_id=%d))";
	
	char sql[256];
	sprintf(sql, format, foodId1, foodId2, foodId1, foodId2, foodId1, foodId2);
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		sqlite3_close(db);
		return;
	}

	int rc = sqlite3_step(stmt);
	if (rc == SQLITE_ROW) {
		foodName1 = [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(stmt, 0)];
		foodName2 = [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(stmt, 1)];
		counteract = sqlite3_column_int(stmt, 2);
		if (counteract == 1)
			self.navigationItem.title = [NSString stringWithFormat: @"%@和%@相克", foodName1, foodName2];
		else
			self.navigationItem.title = [NSString stringWithFormat: @"%@和%@相宜", foodName1, foodName2];

        content = [[WLCrypto base64_decrypt_by_aes:  [NSString stringWithUTF8String: (const char *)sqlite3_column_text(stmt, 3) ] with: 0] copy];
	}
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.opaque = NO;
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"tableview.png"]];
	
	fontSize = [FoodSettings fontSizeFromSetting];
	
	//UIBarButtonItem* weiboItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemReply target:self action:@selector(done:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[foodName1 release];
	[foodName2 release];
	[content release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (IBAction) counteract_show:(id)sender {
    NSInteger count = [self.navigationController.viewControllers count];
    if (count == 4) {
        FoodSummaryViewController *controller = (FoodSummaryViewController *)[self.navigationController.viewControllers objectAtIndex: 1];
        controller.foodId = foodId2;
		controller.toChange = YES;
        [self.navigationController popToViewController: controller animated: YES];
    } else if (count == 5) {
        FoodSummaryViewController *controller = (FoodSummaryViewController *)[self.navigationController.viewControllers objectAtIndex: 2];
        controller.foodId = foodId2;
		controller.toChange = YES;
        [self.navigationController popToViewController: controller animated: YES];
    }
    //NSLog(@"----- %d",[self.navigationController.viewControllers count]);
    //[self.navigationController popToRootViewControllerAnimated: NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		if (counteract == 1) {
			return @"相克的后果";
		} else
			return @"相宜的效果";
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 130;
	} else {
		CGRect rect = [[UIScreen mainScreen] bounds];
		CGSize size = rect.size;

		CGSize stringSize = [content sizeWithFont: [UIFont fontWithName: @"Helvetica" size: fontSize] constrainedToSize: size lineBreakMode: UILineBreakModeWordWrap];
		
		return stringSize.height + 80;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d", indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
		return cell;
	}
	
	CGRect rect = [[UIScreen mainScreen] bounds];
	CGSize size = rect.size;
    
    // Configure the cell...
    if (indexPath.section == 0) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, 120, 120)];
		UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(size.width - 30 - 120 + 5, 5, 120, 120)];
		/*UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake((size.width - 30) / 2 - 10, 55, 20, 20)];
		label.text = @"+";
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont fontWithName: @"Helvetica" size: 30];*/
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.backgroundColor = [UIColor clearColor];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docDir = [paths objectAtIndex:0];
		if (docDir) {
			NSString *image_path = [NSString stringWithFormat: @"%@/images/%d.png", docDir, foodId1];
			if ([[NSFileManager defaultManager] fileExistsAtPath:image_path]) {
				[imageView setImage: [UIImage imageWithContentsOfFile: image_path]];
			} else
				[imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId1]]];
			
			image_path = [NSString stringWithFormat: @"%@/images/%d.png", docDir, foodId2];
			if ([[NSFileManager defaultManager] fileExistsAtPath:image_path]) {
				[button setImage: [UIImage imageWithContentsOfFile: image_path] forState: UIControlStateNormal];
			} else
				[button setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId2]] forState: UIControlStateNormal];
			[button setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId2]] forState: UIControlStateNormal];
		} else {
			[imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId1]]];
		}
		
		//[imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId1]]];
		
		
		
		button.contentMode = UIViewContentModeScaleAspectFit;

		[button addTarget: self action: @selector(counteract_show:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview: imageView];
		[cell.contentView addSubview: button];
		//[cell.contentView addSubview: label];
		
		[imageView release];
		[button release];
		//[label release];
	} else {
		CGSize stringSize = [content sizeWithFont:[UIFont fontWithName: @"Helvetica" size: fontSize] constrainedToSize: size lineBreakMode: UILineBreakModeWordWrap];
		UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(5, 5, size.width - 30, stringSize.height + 70)];
		textView.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
		textView.text = content;
		textView.backgroundColor = [UIColor clearColor];
		textView.editable = NO;
		[cell.contentView addSubview: textView];
		[textView release];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
