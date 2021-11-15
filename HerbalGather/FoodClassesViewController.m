//
//  FoodClassesViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoodClassesViewController.h"
#import "FoodListViewController.h"
#import "FoodSettings.h"

#import "FoodStruct.h"

//const NSString *english_name[] = {@"disposition", @"flavour", @"meridian"};
//NSString *chinese_name[] = {@"五性", @"五味", @"归经"};
//const NSString *section_names[] = {@"性", @"味", @"归入"};
//const NSString *dispositionColor[] = {@"hei.png", @"qing.png", @"huang.png", @"bai.png", @"hong.png"};
const NSString *flavour_pngs[] = {@"suan.png", @"ku.png", @"gan.png", @"xin.png", @"xian.png"};
const NSString *disposition_pngs[] = {@"cold.png", @"cool.png", @"normal.png", @"warm.png", @"hot.png"};
//const NSString *flavourColor[] = {@"qing.png", @"hong.png", @"huang.png", @"bai.png", @"hei.png"};

extern NSString *dispositions[];
extern NSString *flavours[];

const NSString *meridians_full[] = { @"手太阴肺经", @"手阳明大肠经", @"足阳明胃经", @"足太阴脾经",
	@"手少阴心经", @"手太阳小肠经", @"足太阳膀胱经", @"足少阴肾经",
	@"手厥阴心包经", @"手少阳三焦经", @"足少阳胆经", @"足厥阴肝经"};

@implementation FoodClassesViewController {
	NSInteger fontSize;
}

@synthesize delegate = _delegate;
@synthesize kind;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

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
    kind_array = [[NSMutableArray alloc] init];
    if (kind == 0) {
        for (int i = 0; i < 5; i++) {
			FoodStruct *fs = [FoodStruct new];
			fs.name = dispositions[i];
			fs.photo = (NSString *)disposition_pngs[i];
            [kind_array addObject: fs];
        }
        self.navigationItem.title = @"五性";
    } else if (kind == 1) {
        for (int i = 0; i < 5; i++) {
			FoodStruct *fs = [FoodStruct new];
			fs.name = flavours[i];
			fs.photo = (NSString *)flavour_pngs[i];
            [kind_array addObject: fs];
        }
        self.navigationItem.title = @"五味";
    } else if (kind == 2) {
        for (int i = 0; i < 12; i++) {
			FoodStruct *fs = [FoodStruct new];
			fs.name = ( NSString *)meridians_full[i];
			fs.photo = [NSString stringWithFormat:@"m%d", i];
            [kind_array addObject: fs];
        }
        self.navigationItem.title = @"归经";
    }
    
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"aa" style:UIBarButtonItemStyleDone target:self action: @selector(done:)];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(done:)]; 
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemReply target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = backItem;
    //self.navigationBar.backItem.backBarButtonItem = backItem;
    //self.navigationController.navigationBar.backItem.backBarButtonItem = backItem;
	
	fontSize = [FoodSettings fontSizeFromSetting];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [kind_array release];
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
    //[self.navigationController popViewControllerAnimated: YES];
    [self.delegate classesViewControllerDidFinish: self];
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
    return [kind_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	FoodStruct *fs = [kind_array objectAtIndex:indexPath.row];
    // Configure the cell...
	[cell.textLabel setText: fs.name];
	[cell.imageView setImage: [UIImage imageNamed: fs.photo]];
	/* 修改cell的字体 */
	cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size: fontSize];
    
	/* 设置cell样式 */
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    
    FoodListViewController *detailViewController = [[FoodListViewController alloc] initWithNibName:@"FoodListViewController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    detailViewController.kind = kind;
    detailViewController.classId = 1 << indexPath.row;
    detailViewController.title = [[kind_array objectAtIndex: indexPath.row] name];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [FoodListViewController release];
}

@end
