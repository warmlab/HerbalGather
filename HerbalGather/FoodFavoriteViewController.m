//
//  FoodFavoriteViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "FoodFavoriteViewController.h"
#import "FoodSummaryViewController.h"
#import "FoodData.h"
#import "FoodInfo.h"
#import "FoodSettings.h"

extern const char *path;

@implementation FoodFavoriteViewController
{
	NSMutableArray *favoriteList;
	NSInteger fontSize;
}

@synthesize delegate = _delegate;

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = @"收藏";
	favoriteList = [[NSMutableArray alloc] init];
	
	UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemReply target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = backItem;
	
	fontSize = [FoodSettings fontSizeFromSetting];
}

static void clear_list(NSMutableArray *list) {
	for (FoodInfo *data in list) {
		[data.foodName release];
		[data release];
	}
	
	[list removeAllObjects];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	clear_list(favoriteList);
	[favoriteList release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	clear_list(favoriteList);
	
	int rc;
	sqlite3 *db;
	if ((rc = sqlite3_open(path, &db))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}
	
	char *sql = "SELECT f.id, f.name FROM foods_favorite l, foods_food f where l.food_id=f.id";
	sqlite3_stmt *stmt;
	if ((rc = sqlite3_prepare(db, sql, -1, &stmt, NULL))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}

	rc = sqlite3_step(stmt);
	while (rc == SQLITE_ROW) {
		FoodInfo *data = [[FoodInfo alloc] init];
		data.foodId = sqlite3_column_int(stmt, 0);
		data.foodName = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(stmt, 1)];
		[favoriteList addObject: data];
		
		rc = sqlite3_step(stmt);
	}
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);

	[self.tableView reloadData];
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

- (IBAction)done:(id)sender
{
    //[self.navigationController popViewControllerAnimated: YES];
    [self.delegate favoriteViewControllerDidFinish: self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [favoriteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	FoodInfo *cellValue = [favoriteList objectAtIndex:indexPath.row];
	[cell.textLabel setText: cellValue.foodName];
	[cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat:@"%d.png", cellValue.foodId]]];
    
	/* 设置cell样式 */
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	/* 修改cell的字体 */
	cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		FoodInfo *data = [favoriteList objectAtIndex: indexPath.row];
		
		[FoodData deleteFavoriteFood: data.foodId];
		
		[favoriteList removeObject: data];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

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
    FoodSummaryViewController *summaryViewController = [[FoodSummaryViewController alloc] initWithNibName:@"FoodSummaryViewController" bundle:nil];
	// ...
	// Pass the selected object to the new view controller.
    summaryViewController.foodId = [[favoriteList objectAtIndex: indexPath.row] foodId];
    [self.navigationController pushViewController:summaryViewController animated:YES];
    [summaryViewController release];
}

@end
