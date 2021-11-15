//
//  FoodUpdateViewController.m
//  HerbalGather
//
//  Created by 恶狼 on 12-12-16.
//
//

#import "FoodUpdateViewController.h"

#import "FoodData.h"

#import "WLCrypto.h"

//#import <CGImageDestination.h>
#import <ImageIO/CGImageDestination.h>
#import <ImageIO/CGImageProperties.h>

@interface FoodUpdateViewController ()

enum {
	FOOD_CHECK_UPDATE,
	FOOD_UPDATE,
	FOOD_GET_IMAGE,
	FOOD_ERROR = -1,
};

@end

@implementation FoodUpdateViewController
{
	//NSInteger status_type;
	NSString *status_text;
	NSMutableArray *food_array;
	NSMutableArray *alias_array;
	NSMutableArray *relation_array;
	//WLNetwork *wlnetwork;
	
	NSInteger status_code;
	NSUInteger content_length;
	NSString *content_type;
	
	UIProgressView *progressView;
	UILabel *label;
	
	NSInteger food_count;
	
	NSInteger new_version;
	NSInteger new_encrypt;
	NSInteger local_version;
	
	NSString *food_json_file;
	
	NSMutableArray *networks;
}

void FetchReadCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo);
void *CFClientRetain(void *object);
void CFClientRelease(void *object);
CFStringRef CFClientDescribeCopy(void *object);

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *checkUpdateItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(checkUpdate:)];
	self.navigationItem.rightBarButtonItem = checkUpdateItem;
	//[checkUpdateItem release];
	
	self.navigationItem.title = @"更新食物";
	food_json_file = [NSString stringWithFormat: @"%@/foods_data.json",  NSTemporaryDirectory()];
	
	networks = [NSMutableArray new];
	
	food_array = [[NSMutableArray alloc] init];
	alias_array = [[NSMutableArray alloc] init];
	relation_array = [[NSMutableArray alloc] init];
    progressView = [[UIProgressView alloc] initWithFrame: CGRectMake(42, 18, 248, 44)];
	
	/*
	if ([[NSFileManager defaultManager] fileExistsAtPath: food_json_file]) {
		[self resumeLastUpdate];
		
		progressView.hidden = NO;
		//status_text = @"刷新查看数据是否有更新";
	}*/
	content_length = NSURLResponseUnknownLength;
	progressView.progress = 0;
	
	progressView.hidden = YES;
	status_text = @"刷新查看数据是否有更新";
	//status_type = FOOD_CHECK_UPDATE;
	food_count = 0;
}

- (void) viewDidUnload
{
	[networks release];
	//[checkUpdateItem release];
	[food_array release];
	[alias_array release];
	[relation_array release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkUpdate:(id)sender
{
	/*[food_array removeAllObjects];
	[food_array addObject: @"您的数据已经是最新版本"];
	[self.tableView reloadData];*/
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	status_text = @"正在检查食物版本";
	//[self.tableView reloadData];
	
	CFStringRef request_url = CFSTR("http://www.warmlab.com/foods/get_version");
	CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, request_url, NULL);
	WLNetwork *network = [WLNetwork networkURL: url delegate: self tag: FOOD_CHECK_UPDATE name: nil];
}

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
	/*[food_array removeAllObjects];
	 [food_array addObject: @"您的数据已经是最新版本"];
	 [self.tableView reloadData];*/
	if (buttonIndex == 1)  {
		status_text = @"刷新查看数据是否有更新";
		progressView.hidden = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self.tableView reloadData];
		return;
	}
	// set refresh button to unable
	//status_type = FOOD_UPDATE;
	progressView.hidden = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	CFStringRef request_url = CFStringCreateWithFormat(NULL, NULL, CFSTR("http://www.warmlab.com/foods/update?version=%d"), [FoodData getCurrentVersion]);
	CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, request_url, NULL);
	WLNetwork *network = [WLNetwork networkURL: url delegate: self tag: FOOD_UPDATE name: nil];
}

#pragma mark - WLNetworkDelegate

- (void)network:(WLNetwork *)network didFailWithError:(NSError *)error
{
	NSLog(@"An error occurred %d", error.code);
	
	//[food_array removeAllObjects];
	status_text = @"不能检查数据版本，请检查网络连接";
	//status_type = FOOD_ERROR;
	[self.tableView reloadData];
}

- (void)network:(WLNetwork *)network didReceiveStatusCode:(NSInteger)statusCode contentLength:(NSUInteger)contentLength contentType:(NSString *)contentType
{
	status_code = statusCode;
	content_length = contentLength;
	content_type = [contentType copy];
	NSLog(@"response status code: %d -- Content-Length: %d -- Content-Type: %@", status_code, content_length, content_type);
	progressView.hidden = NO;
}

- (void)networkDidReceiveData:(WLNetwork *)network byteRead:(NSUInteger)byteNumber
{
	//if (content_length == NSURLResponseUnknownLength && network.tag != FOOD_GET_IMAGE) {
		//[progressView setProgress: 0.01];
	//} else {
	float percent;
	if (network.tag == FOOD_UPDATE) {
		percent =  progressView.progress + ((float)byteNumber /  content_length / 2);
	} else if (network.tag == FOOD_CHECK_UPDATE)
		percent = progressView.progress + ((float)byteNumber /  content_length) ;
	else if (network.tag == FOOD_GET_IMAGE)
		percent = [progressView progress] + (float)byteNumber / content_length / food_array.count / 2;
	if (percent > 1.0)
		percent = 1.0;
	[progressView setProgress: percent];
	//}
	progressView.hidden = NO;
	//[self.tableView reloadData];
}

- (NSInteger) analysis_food_version: (NSDictionary *) dic
{
	new_version = [[dic objectForKey: @"version"] integerValue];
	new_encrypt = [[dic objectForKey:@"encrypt"] integerValue];
	local_version = [FoodData getCurrentVersion];
	NSLog(@"current data version in server is: %d and local data version is %d", new_version, local_version);
	if (local_version >= new_version) {
		//[food_array removeAllObjects];
		status_text =  @"您的食物已经是最新版本";
		progressView.hidden = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self.tableView reloadData];
	} else {
		// Download new version data from server
		//[food_array removeAllObjects];
		status_text = @"";
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"有新食物，您是否下载？"
									  delegate: self
									  cancelButtonTitle:@"不，下次吧"
									  destructiveButtonTitle:@"是，我确定"
									  otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
		
		//status_type = FOOD_CHECK_UPDATE;
		progressView.hidden = NO;
		[self.tableView reloadData];
	}
	
	return 0;
}

- (NSInteger) analysis_food_data: (NSDictionary *) dic
{
	//status_type = FOOD_UPDATE;
	progressView.hidden = NO;
	
	[food_array removeAllObjects];
	[alias_array removeAllObjects];
	[relation_array removeAllObjects];
	
	[food_array  addObjectsFromArray: [dic objectForKey: @"foods"]];
	[alias_array addObjectsFromArray: [dic objectForKey: @"alias"]];
	[relation_array addObjectsFromArray: [dic objectForKey: @"relations"]];
	
	[self.tableView reloadData];
	
	for (NSDictionary *d in food_array) {
		NSInteger pk = [[d objectForKey: @"id"] integerValue];
		NSInteger vn = [[d objectForKey: @"version"] integerValue];
		// 
		CFStringRef request_url  = CFStringCreateWithFormat(NULL, NULL, CFSTR("http://www.warmlab.com/foods/get_food_photo?version=%d&food=%d"), vn, pk);
		CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, request_url, NULL);
		WLNetwork *network = [WLNetwork networkURL: url delegate: self tag: FOOD_GET_IMAGE name: [NSString stringWithFormat:@"%d.png", pk]];
	}
	
	return 0;
}

- (void)networkDidFinishLoading:(WLNetwork *)connection
{
	//NSString *version_string = [[NSString alloc] initWithData: connection.data encoding:NSUTF8StringEncoding];
	//NSLog(@"Finish loading: %@", version_string);
	
	//BOOL b = [NSJSONSerialization isValidJSONObject: version_json];
	//NSLog(@"%d", b);
	if (status_code == 200) {
		NSError *error;
		if (connection.tag == FOOD_GET_IMAGE && ![content_type caseInsensitiveCompare: @"image/png"]) {
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docDir = [paths objectAtIndex:0];
				NSString *image_file = [NSString stringWithFormat: @"%@/images/%@",  docDir, connection.name];
			UIImage *image_org = [UIImage imageWithData: connection.data];
			NSData *data_conv = UIImagePNGRepresentation(image_org);
			//UIImage *image = [UIImage imageWithData: data_conv];
			
				if ([data_conv writeToFile: image_file atomically: YES]) {
			//CGImageDestinationRef		destRef				= CGImageDestinationCreateWithData((CFMutableDataRef)connection.data, CFSTR("image/png"), 1, NULL);
			//if (destRef)
		
					food_count++;
				}
			
			if (food_count == food_array.count) {
				for (NSDictionary *d in food_array) {
					[FoodData updateFood: d];
					
					// move png file to Documents directory
					//[NSFileManager defaultManager] moveItemAtPath:<#(NSString *)#> toPath:<#(NSString *)#> error:<#(NSError **)#>
				}
				
				for(NSDictionary *d in alias_array) {
					[FoodData updateAlias: d];
				}
				
				for(NSDictionary *d in relation_array) {
					[FoodData updateRelation: d];
				}
				
				// Convert normal image to iOS format
				
				//NSError *error;
				//[[NSFileManager defaultManager] removeItemAtPath: food_json_file error: &error];
				[FoodData updateCurrentVersion: new_version encrypt: new_encrypt];
				
				self.navigationItem.rightBarButtonItem.enabled = YES;
				status_text = @"更新完成";
				progressView.hidden = YES;
				[self.tableView reloadData];
			}
		} else if (![content_type caseInsensitiveCompare: @"application/json"]) {
			NSDictionary *json = [NSJSONSerialization JSONObjectWithData: connection.data options: kNilOptions error: &error];
			if (connection.tag == FOOD_UPDATE) {
				//[connection.data writeToFile:  food_json_file atomically:NO];
				[self analysis_food_data: json];
			} else if (connection.tag == FOOD_CHECK_UPDATE) {
				[self analysis_food_version: json];
				progressView.progress = 0;
			}
		}
	} else {
		NSLog(@"request is not success");
		status_text = @"更新失败，请再次尝试";
		//status_type = FOOD_ERROR;
		progressView.hidden = YES;
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	if (food_array.count > 0)
		return 2;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"状态";
	return @"食物";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (section == 0)
		return 1;
    return food_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    // Configure the cell...
	if (indexPath.section == 0) {
		NSString *CellIdentifier = @"StatusCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		if (progressView.isHidden) {
			cell.textLabel.text = status_text;
			[cell.imageView setImage: [UIImage imageNamed: @"info.png"]];
		} else {
			cell.textLabel.text = @"";
			[cell.imageView setImage: [UIImage imageNamed: @"info.png"]];
			[cell.contentView addSubview: progressView];
		}
		/*
		//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
		UIImage *image;
		if (status_type != FOOD_UPDATE)
			image = [UIImage imageNamed: @"refresh.png"];
		else
			image = [UIImage imageNamed: @"download.png"];
		CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
		button.frame = frame;
		button.backgroundColor = [UIColor clearColor];
		[button setBackgroundImage: image forState: UIControlStateNormal];
		[button addTarget:self action:@selector(do_action:) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = button;
		 */
		
		return cell;
	} else {
		NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}

		cell.textLabel.text = [WLCrypto base64_decrypt_by_aes: [[food_array objectAtIndex: indexPath.row] objectForKey: @"name"] with: 0];
		[cell.imageView setImage: [UIImage imageNamed: @"new.png"]];
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		return cell;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
