//
//  FoodListViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <sqlite3.h>

#import "FoodInfo.h"
#import "FoodListViewController.h"
#import "FoodSummaryViewController.h"
#import "FoodSettings.h"

const NSString *english_name[] = {@"disposition", @"flavour", @"meridian"};
extern char *path;

@implementation FoodListViewController {
	NSInteger fontSize;
}

@synthesize kind, classId;

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


static NSInteger food_list_init(NSMutableArray *list, NSInteger section, NSInteger select_id) {
	char *format = "select id, name from foods_food where (%s & %d)=%d";
	
	sqlite3 *db;
	if (sqlite3_open(path, &db)) {
        NSLog(@"sqlite3_open error: %s", sqlite3_errmsg(db));
		sqlite3_close(db);
		return 1;
	}
	
	char sql[128];
	sprintf(sql, format, [english_name[section] UTF8String], select_id, select_id);
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		sqlite3_close(db);
		return 1;
	}
	
	int rc = sqlite3_step(stmt);
	while (rc == SQLITE_ROW) {
		FoodInfo *key_value = [FoodInfo new];
		key_value.foodId = sqlite3_column_int(stmt, 0);
		[key_value setUTF8Value: (char *)sqlite3_column_text(stmt, 1)];
		[list addObject: key_value];
		rc = sqlite3_step(stmt);
	}
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    foodList = [[NSMutableArray alloc] init];
    food_list_init(foodList, kind, classId);
	
	fontSize = [FoodSettings fontSizeFromSetting];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [foodList release];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [foodList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    FoodInfo *cellValue = [foodList objectAtIndex:indexPath.row];
	[cell.textLabel setText: cellValue.foodName];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
	if (docDir) {
		NSString *image_path = [NSString stringWithFormat: @"%@/images/%d.png", docDir, cellValue.foodId];
		if ([[NSFileManager defaultManager] fileExistsAtPath:image_path]) {
			[cell.imageView setImage: [UIImage imageWithContentsOfFile: image_path]];
		} else
			[cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", cellValue.foodId]]];
	} else {
		[cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", cellValue.foodId]]];
	}
	
	//[cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat:@"%d.png", cellValue.foodId]]];
    
	/* 设置cell样式 */
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	/* 修改cell的字体 */
	cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
    
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
    FoodSummaryViewController *summaryViewController = [[FoodSummaryViewController alloc] initWithNibName:@"FoodSummaryViewController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    summaryViewController.foodId = [[foodList objectAtIndex: indexPath.row] foodId];
	summaryViewController.toChange = NO;
    [self.navigationController pushViewController:summaryViewController animated:YES];
    [summaryViewController release];
}

@end
