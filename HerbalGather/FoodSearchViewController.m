//
//  FoodSearchViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#import "FoodSearchViewController.h"
#import "FoodSummaryViewController.h"
#import "FoodInfo.h"
#import "FoodSettings.h"

extern char *path;

@implementation FoodSearchViewController {
	NSInteger fontSize;
}

char *scope_names[] = {"name", "efficacy", "shiliao"};
NSInteger scope;

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"搜索";
    foodList = [[NSMutableArray alloc] init];
#ifdef SEARCHLITE
    //foodSearchBar.scopeButtonTitles = nil;
    self.searchDisplayController.searchBar.scopeButtonTitles = nil;
    self.searchDisplayController.searchBar.placeholder = @"食物";
    scope = 0;
#else
    if (scope == 0) {
        self.searchDisplayController.searchBar.placeholder = @"食物";
    } else if (scope == 1) {
        self.searchDisplayController.searchBar.placeholder = @"功效";
    } else {
        self.searchDisplayController.searchBar.placeholder = @"食疗";
    }
#endif
	
	fontSize = [FoodSettings fontSizeFromSetting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: YES]; 
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden: NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [foodList release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

static int search_food(NSMutableArray *list, NSString *text) {
	int rc;
	sqlite3_stmt *stmt;
	char sql[64];
	
	if (!scope) {
		strcpy(sql, "SELECT food_id, name FROM foods_alias WHERE name like ?");
	} else {
		sprintf(sql, "SELECT id, name FROM foods_food WHERE %s like ?", scope_names[scope]);
	}
    
	sqlite3 *db;
	if (sqlite3_open(path, &db)) {
		sqlite3_close(db);
		return 1;
	}
	
	rc = sqlite3_prepare(db, sql, -1, &stmt, NULL);
	if (rc != SQLITE_OK) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 1;
	}
	
	NSString *name = [[NSString alloc] initWithFormat: @"%%%@%%", text];
	rc = sqlite3_bind_text(stmt, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
	if( rc != SQLITE_OK ) {
		[name release];
        NSLog(@"sqlite3_bind_text(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
        return 1;
    }
	[name release];
	
	rc = sqlite3_step(stmt);
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

static int clearFoodList(NSMutableArray *list) {
	for (FoodInfo *key_value in list) {
		[key_value.foodName release];
		[key_value release];
	}
	
	[list removeAllObjects];
    
	return 0;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	/*
     remove_food_result(food_result);
     
     if (searchText == nil || [searchText isEqualToString: @""]){
     return;
     }
     
     if (!search_food(food_result, [self.searchDisplayController.searchBar text]))
     [self.searchDisplayController.searchResultsTableView reloadData];*/
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange: (NSInteger)selectedScope {
	scope = selectedScope;
	if (scope == 0) {
		searchBar.placeholder = @"食物";
	} else if (scope == 1) {
		searchBar.placeholder = @"功效";
	} else {
		searchBar.placeholder = @"食疗";
	}
    
	searchBar.text = searchBar.text;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	//[food_result removeAllObjects];
	//[self.searchDisplayController.searchResultsTableView reloadData];
    [self.delegate searchViewControllerDidFinish:self];
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	//[self search_food];
	[self.searchDisplayController.searchResultsTableView reloadData];
	//remove_food_result(old_result);
	//[old_result addObjectsFromArray: food_result];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	clearFoodList(foodList);
	
	if (searchString == nil || [searchString isEqualToString: @""]){
		return YES;
	}
	
	if (!search_food(foodList, [self.searchDisplayController.searchBar text]))
		//[self.searchDisplayController.searchResultsTableView reloadData];
		return YES;
	else {
		return NO;
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
	//tableView.backgroundColor = self.tableView.backgroundColor;
	//tableView.separatorColor = self.tableView.separatorColor;
	//self.tableView.backgroundColor = [UIColor redColor];
	/*[controller.searchBar setShowsCancelButton:YES animated:NO];
     for (UIView *subview in [controller.searchBar subviews]) {
     if ([subview isKindOfClass:[UIButton class]]) {
     [(UIButton *)subview setTitle:@"_____" forState:UIControlStateNormal];
     }
     }*/
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSLog(@”contacts error in num of row”);
	return [foodList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//if(tableView == self.searchDisplayController.searchResultsTableView){
    // search view population
	//}
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	
	//NSLog(@"indexPath.row: %d", indexPath.row);
	FoodInfo *cellValue = [foodList objectAtIndex: indexPath.row];
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
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	/* 修改cell的字体 */
	cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
	
	return cell;
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	// Navigation logic may go here. Create and push another view controller.
    FoodSummaryViewController *summaryViewController = [[FoodSummaryViewController alloc] initWithNibName:@"FoodSummaryViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    summaryViewController.foodId = [[foodList objectAtIndex: indexPath.row] foodId];
    [self.navigationController pushViewController:summaryViewController animated:YES];
    [summaryViewController release];
}

@end
