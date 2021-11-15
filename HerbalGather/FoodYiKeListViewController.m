//
//  FoodYiKeListViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <sqlite3.h>
#import "FoodYiKeListViewController.h"
#import "FoodCounteractViewController.h"
#import "FoodSettings.h"
#import "FoodInfo.h"

extern char *path;

static NSString *titles[] = {@"相宜", @"相克"};

@implementation FoodYiKeListViewController {
	NSMutableDictionary *yiJiDic;
	NSInteger fontSize;
}

@synthesize foodId;

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
    yiJiDic = [[NSMutableDictionary alloc] initWithCapacity: 4];
    
	char *format = "select t.name, t.food_id, f.name, t.relation \
                    from (select f.name, (case when r.food1_id = f.id then r.food2_id else r.food1_id end) as food_id, r.relation \
                            from foods_food f, foods_relation r \
                            where f.id = %d and (f.id = r.food1_id or f.id = r.food2_id)) t, foods_food f \
                    where t.food_id=f.id;";
    
	sqlite3 *db;
	if (sqlite3_open(path, &db)) {
		sqlite3_close(db);
		return;
	}
	
	char sql[512];
	sprintf(sql, format, foodId);
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		sqlite3_close(db);
		return;
	}
	
	NSMutableArray *yiList = [[NSMutableArray alloc] initWithCapacity: 16];
	NSMutableArray *jiList = [[NSMutableArray alloc] initWithCapacity: 16];
	
	NSInteger counteract = 0;
	NSString *title;
	int rc = sqlite3_step(stmt);
	if (rc == SQLITE_ROW) {
		title = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
        
		FoodInfo *key_value = [FoodInfo new];
		key_value.foodId = sqlite3_column_int(stmt, 1);
		key_value.foodName = [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(stmt, 2)];
        //key_value.yike = sqlite3_column_int(stmt, 3);
		
		NSInteger yj = sqlite3_column_int(stmt, 3);
		
		if (yj == 1) {
			[jiList addObject: key_value];
		} else
			[yiList addObject: key_value];
		
		counteract |= yj;
	}
	
	rc = sqlite3_step(stmt);
	while (rc == SQLITE_ROW) {
		FoodInfo *key_value = [FoodInfo new];
		key_value.foodId = sqlite3_column_int(stmt, 1);
		key_value.foodName = [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(stmt, 2)];
        //key_value.yike = sqlite3_column_int(stmt, 3);
		
		NSInteger yj = sqlite3_column_int(stmt, 3);
		
		if (yj == 1) {
			[jiList addObject: key_value];
		} else
			[yiList addObject: key_value];
		
		counteract |= yj;
		
		rc = sqlite3_step(stmt);
	}

	if (counteract == 3) {
		[self.navigationItem setTitle: [NSString stringWithFormat: @"%@－相宜相克", title]];
	} else if (counteract == 2) {
		[self.navigationItem setTitle: [NSString stringWithFormat: @"%@－相宜", title]];
	}else if (counteract == 1) {
		[self.navigationItem setTitle: [NSString stringWithFormat: @"%@－相克", title]];
	}
	
	if ([yiList count] > 0)
		[yiJiDic setValue: yiList forKey: titles[0]];
	if ([jiList count] > 0)
		[yiJiDic setValue: jiList forKey: titles[1]];
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.opaque = NO;
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"tableview.png"]];
	
	fontSize = [FoodSettings fontSizeFromSetting];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [yikeList release];
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
    return [yiJiDic count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if ([yiJiDic count] == 1) {
		return [[[yiJiDic allValues] objectAtIndex: 0] count];
	} else
		return [[yiJiDic valueForKey: titles[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([yiJiDic count] == 1) {
		return [[yiJiDic allKeys] objectAtIndex: 0];
	} else
		return titles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSMutableArray *array;
    // Configure the cell...
	if ([yiJiDic count] == 1) {
		array = [[yiJiDic allValues] objectAtIndex: 0];
	} else {
		array = [yiJiDic valueForKey: titles[indexPath.section]];
	}
    FoodInfo *cellValue = [array objectAtIndex:indexPath.row];
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
	
	//[cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", cellValue.foodId]]];
    
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
    FoodCounteractViewController *detailViewController = [[FoodCounteractViewController alloc] initWithNibName:@"FoodCounteractViewController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    detailViewController.foodId1 = foodId;
	if ([yiJiDic count] == 1)
		detailViewController.foodId2 = [[[[yiJiDic allValues] objectAtIndex: 0] objectAtIndex: indexPath.row] foodId];
	else
		detailViewController.foodId2 = [[[yiJiDic valueForKey: titles[indexPath.section]] objectAtIndex: indexPath.row] foodId];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

@end
