//
//  FoodSummaryViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <sqlite3.h>

#import "FoodSummaryViewController.h"
#import "FoodYiKeListViewController.h"
#import "FoodData.h"
#import "FoodSettings.h"
#import "WLCrypto.h"

extern char *path, *favorite_path;
extern NSString *flavours[];
extern NSString *dispositions[];
extern NSString *meridians[];

static NSString *titles[] = {@"名称", @"性味", @"归经", @"功效", @"食疗", @"食养", @"食忌", @"其他"};

@implementation FoodSummaryViewController {
	NSMutableArray *array;
	NSInteger fontSize;
}

@synthesize foodId, toChange;

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

static NSString *convertToXingwei(NSInteger disposition, NSInteger flavour) {
	NSMutableArray *array = [NSMutableArray new];
	for (int i = 0; i < 5; i++) {
		if (disposition & 1 << i) {
			[array addObject: dispositions[i]];
		}
	}
    
    NSMutableArray *array2 = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
		if (flavour & 1 << i) {
			[array2 addObject: flavours[i]];
		}
	}
    
	NSString *str = [[array componentsJoinedByString: @"，"] stringByAppendingFormat: @"；%@", [array2 componentsJoinedByString: @"，"]];
    
	[array release];
    [array2 release];
    
	return str;
}

static NSString *convertToFlavour(NSInteger v) {
	NSMutableArray *array = [NSMutableArray new];
	for (int i = 0; i < 5; i++) {
		if (v & 1 << i) {
			[array addObject: flavours[i]];
		}
	}
    
	NSString *str = [array componentsJoinedByString: @"，"];
	[array release];
    
	return str;
}

static NSString *convertToMeridian(NSInteger v) {
	NSMutableArray *array = [NSMutableArray new];
	for (int i = 0; i < 12; i++) {
		if (v & 1 << i) {
			[array addObject: meridians[i]];
		}
	}
    
	NSString *str = [array componentsJoinedByString: @"，"];
	[array release];
    
	return str;
}

#pragma mark - Acktion

-(IBAction)segmentedAction:(id)sender {
    UISegmentedControl* segmentedControl = (UISegmentedControl *)sender;
    if ([segmentedControl selectedSegmentIndex] == 0) {
#ifdef FOODLITE
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"食物养生-Lite版不支持收藏功能，要下载完整版吗？"
									  delegate: self
									  cancelButtonTitle: @"不，以后再说"
									  destructiveButtonTitle: @"好，去下载"
									  otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
#else
		if ([FoodData queryFavoriteFood: foodId]) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc]
										  initWithTitle:@"该食物已经被收藏"
										  delegate: nil
										  cancelButtonTitle: @"好，我知道了"
										  destructiveButtonTitle: nil
										  otherButtonTitles:nil];
			[actionSheet showInView:self.view];
			[actionSheet release];
		} else {
			//UIAlertView *alertView = [UIAlertView alloc] init
			UIActionSheet *actionSheet = [[UIActionSheet alloc]
										  initWithTitle:@"您确定要收藏该食物？"
										  delegate: self
										  cancelButtonTitle:@"不，点错了"
										  destructiveButtonTitle:@"是，我确定"
										  otherButtonTitles:nil];
			[actionSheet showInView:self.view];
			[actionSheet release];
		}
#endif
    } else {
        FoodYiKeListViewController *yikeListViewController = [[FoodYiKeListViewController alloc] initWithNibName:@"FoodYiKeListViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        yikeListViewController.foodId = foodId;
        [self.navigationController pushViewController:yikeListViewController animated:YES];
        [yikeListViewController release];
    }
}

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
	switch (buttonIndex) {
		case 0:
#ifdef	FOODLITE
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/cn/app/id475561576?mt=8"]];
#else
			[FoodData insertFavoriteFood: foodId];
#endif
			break;
		default:
			break;
	}
}

- (void) loadData {
	int rc;
    /* 设置右上角button的标题 */
	char sql[256];
	char *format = "select relation from foods_relation where food1_id = %d or food2_id = %d";
	sprintf(sql, format, foodId, foodId);
	
	sqlite3 *db;
	if ((rc = sqlite3_open(path, &db))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}
	
	sqlite3_stmt *stmt;
	if ((rc = sqlite3_prepare(db, sql, -1, &stmt, NULL))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}
	
	NSInteger counteract = 0;
	rc = sqlite3_step(stmt);
	while (rc == SQLITE_ROW) {
        counteract |= sqlite3_column_int(stmt, 0);
		rc = sqlite3_step(stmt);
	}
	
	sqlite3_finalize(stmt);
	
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray array]];
	[segmentedControl setMomentary:YES];
	//[segmentedControl insertSegmentWithImage: [UIImage imageNamed: @"sinaweibo24.png"] atIndex:0 animated: YES];
	//[segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon-triangle-up.png"] atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithImage: [UIImage imageNamed: @"Favorites.png"] atIndex:0 animated: YES];
	//[segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon-triangle-down.png"] atIndex:1 animated:NO];
	//[segmentedControl insertSegmentWithTitle: @"更多" atIndex:1 animated: NO];
	
	UIBarButtonItem * segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView: segmentedControl];
	
	if (counteract) {
		/*
		 UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray array]];
		 [segmentedControl setMomentary:YES];
		 //[segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon-triangle-up.png"] atIndex:0 animated:NO];
		 [segmentedControl insertSegmentWithTitle: @"更多" atIndex:0 animated: NO];
		 //[segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon-triangle-down.png"] atIndex:1 animated:NO]; */
		
		if (counteract == 1) {
			//[self.navigationItem.rightBarButtonItem setTitle: @"相克"];
            [segmentedControl insertSegmentWithTitle: @"相克" atIndex:1 animated: NO];
		} else if (counteract == 2) {
			//[self.navigationItem.rightBarButtonItem setTitle: @"相宜"];
            [segmentedControl insertSegmentWithTitle: @"相宜" atIndex:1 animated: NO];
		} else {
			//[self.navigationItem.rightBarButtonItem setTitle: @"相宜相克"];
            [segmentedControl insertSegmentWithTitle: @"宜克" atIndex:1 animated: NO];
		}
	}
	
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	
	NSMutableArray *a = [NSMutableArray new];
	/* 获取其别名 */
	format = "SELECT name FROM foods_alias WHERE food_id=%d";
	sprintf(sql, format, foodId);
	
	if ((rc = sqlite3_prepare(db, sql, -1, &stmt, NULL))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}
	
	rc = sqlite3_step(stmt);
	while (rc == SQLITE_ROW) {
        [a addObject: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(stmt, 0)]];
		rc = sqlite3_step(stmt);
	}
	[array insertObject: [NSDictionary dictionaryWithObject: [a componentsJoinedByString: @"，"] forKey: titles[0]] atIndex: 0];
	//sqlite3_finalize(stmt);
	[a removeAllObjects];
	[a release];
	
	sqlite3_finalize(stmt);
    
	/* 获取其性味及归经信息 */
	format = "SELECT name, flavour, disposition, meridian, efficacy, shiliao, shiyi, shiji, nature, version FROM foods_food f WHERE f.id=%d";
	sprintf(sql, format, foodId);
	
	if ((rc = sqlite3_prepare(db, sql, -1, &stmt, NULL))) {
		NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return;
	}
	
	rc = sqlite3_step(stmt);
	if (rc == SQLITE_ROW) {
		self.navigationItem.title = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(stmt, 0)];
		//NSString *tmp = [NSString stringWithFormat: @"%d.png", food_content_id];
		//[food_image setImage: [UIImage imageNamed: tmp]];
		//[disposition setText: convertToDisposition(sqlite3_column_int(stmt, 2))];
        [array addObject: [NSDictionary dictionaryWithObject: convertToXingwei(sqlite3_column_int(stmt, 2), sqlite3_column_int(stmt, 1)) forKey: titles[1]]];
		//[flavour_tf setText: [FoodAttribute convertToFlavour: sqlite3_column_int(stmt, 1)]];
		[array addObject: [NSDictionary dictionaryWithObject: convertToMeridian(sqlite3_column_int(stmt, 3)) forKey: titles[2]]];
		[array addObject: [NSDictionary dictionaryWithObject: [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] forKey: titles[3]]];
		[array addObject: [NSDictionary dictionaryWithObject: [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] forKey: titles[4]]];
		int encrypt = sqlite3_column_int(stmt, 9);
        const unsigned char *tmp = sqlite3_column_text(stmt, 6);
        if (tmp)
			[array addObject: [NSDictionary dictionaryWithObject: [[WLCrypto base64_decrypt_by_aes: [NSString  stringWithUTF8String: (const char*)tmp] with: encrypt] copy] forKey: titles[5]]];
		tmp = sqlite3_column_text(stmt, 7);
        if (tmp)
			[array addObject: [NSDictionary dictionaryWithObject: [[WLCrypto base64_decrypt_by_aes: [NSString  stringWithUTF8String: (const char*)tmp] with: encrypt] copy] forKey: titles[6]]];
		[array addObject: [NSDictionary dictionaryWithObject: [[WLCrypto base64_decrypt_by_aes: [NSString  stringWithUTF8String: (const char*)sqlite3_column_text(stmt, 8)] with: encrypt] copy]  forKey: titles[7]]];
		rc = sqlite3_step(stmt);
	}
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	array = [[NSMutableArray alloc] initWithCapacity: 8];

	[self loadData];
	
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
	[array release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if (toChange) {
		[array removeAllObjects];
		[self loadData];
		[self.tableView reloadData];
		toChange = NO;
	}
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[[array objectAtIndex: section] allKeys] objectAtIndex: 0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d", indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
		//[[cell.contentView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
		for (UIView *v in cell.contentView.subviews) {
			[v removeFromSuperview];
		}
	}
    
    // Configure the cell...
	NSDictionary *dict = [array objectAtIndex: indexPath.section];
	NSString *value = [dict.allValues objectAtIndex: 0];
	CGRect rect = [[UIScreen mainScreen] bounds];
	CGSize size = rect.size;
	if (indexPath.section == 0) {
		//UIView *view = [[UIView alloc] initWithFrame: CGRectMake(5, 5, size.width - 30, 130)];
		UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(size.width - 30 - 120 + 5, 5, 120, 120)];
		imageView.backgroundColor = [UIColor clearColor];
		UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(5, 5, size.width - 30 - 120, 120)];
		textView.text = value;
		textView.editable = NO;
		textView.backgroundColor = [UIColor clearColor];
		textView.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docDir = [paths objectAtIndex:0];
		if (docDir) {
			NSString *image_path = [NSString stringWithFormat: @"%@/images/%d.png", docDir, foodId];
			if ([[NSFileManager defaultManager] fileExistsAtPath:image_path]) {
				[imageView setImage: [UIImage imageWithContentsOfFile: image_path]];
			} else
				[imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId]]];
		} else {
			[imageView setImage: [UIImage imageNamed: [NSString stringWithFormat: @"%d.png", foodId]]];
		}
		
		//[view addSubview: textView];
		//[view addSubview: imageView];

		//[cell.contentView addSubview: view];
		[cell.contentView addSubview: textView];
		[cell.contentView addSubview: imageView];
		
		[textView release];
		[imageView release];
	} else {
		CGSize stringSize = [value sizeWithFont:[UIFont fontWithName: @"Helvetica" size: fontSize] constrainedToSize: size lineBreakMode: UILineBreakModeWordWrap];
		UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(5, 5, size.width - 30, stringSize.height + 30)];
		textView.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
		textView.text = value;
		textView.editable = NO;
		textView.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview: textView];
		[textView release];
	}
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 130;
	} else {
		NSDictionary *dict = [array objectAtIndex: indexPath.section];
		NSString *value = [dict.allValues objectAtIndex: 0] ;
		
		CGRect rect = [[UIScreen mainScreen] bounds];
		CGSize size = rect.size;
		
		CGSize stringSize = [value sizeWithFont:[UIFont fontWithName: @"Helvetica" size: fontSize] constrainedToSize: size lineBreakMode: UILineBreakModeWordWrap];
		
		return stringSize.height + 40;
	}
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
