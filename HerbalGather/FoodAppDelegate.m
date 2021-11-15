//
//  FoodAppDelegate.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "FoodAppDelegate.h"

#import "FoodMainViewController.h"

char *path; //, *favorite_path;
const NSString *flavours[] = {@"酸", @"苦", @"甘", @"辛", @"咸", @"涩", @"淡"};
const NSString *dispositions[] = {@"寒", @"凉", @"平", @"温", @"热"};
const NSString *meridians[] = {@"肺", @"大肠", @"胃", @"脾", @"心", @"小肠", @"膀胱", @"肾", @"心包", @"三焦", @"胆", @"肝"};

@implementation FoodAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (void)dealloc
{
    [_window release];
    [_mainViewController release];
    [super dealloc];
}

-(BOOL)prepare_data
{
	// 获取Documents目录
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
	if (!docDir) {
		NSLog(@"Documents directory not found!");
        return NO;
    }
	
	NSString *dbPath = [NSString stringWithFormat: @"%@/foods.db", docDir];
	NSLog(@"%@", dbPath);
    NSString *tmp = [[NSBundle mainBundle] pathForResource: @"foods" ofType: @"db"];
	if (![[NSFileManager defaultManager] fileExistsAtPath: dbPath]) {
		if (tmp) {
			NSError *error;
			if ([[NSFileManager defaultManager] copyItemAtPath: tmp toPath: dbPath error: &error])
				NSLog(@"Succeed in copying food data to Documents dir");
			else {
				NSLog(@"Cannot copy food data to Documents dir");
				dbPath = tmp;
			}
		} else {
			NSLog(@"Cannot find food data in application!");
			return NO;
		}
	} else {
		NSLog(@"food data already existed in Documents directory, the app will use it");
	}
	

	// make images directory
	NSString *images_path = [docDir stringByAppendingPathComponent: @"images"];
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath: images_path]) {
		if ([[NSFileManager defaultManager] createDirectoryAtPath: images_path withIntermediateDirectories: NO attributes: NULL error: &error]) {
#if 0
			for (int i = 1; i < 10000; i++) {
				NSString *tmp = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"%d", i]  ofType: @"png"];
				if ([[NSFileManager defaultManager] fileExistsAtPath: tmp]) {
					if (![[NSFileManager defaultManager] copyItemAtPath: tmp toPath: [NSString stringWithFormat: @"%@/%d.png", images_path, i] error: &error])
						NSLog(@"Cannot copy image file %d.png to Documents", i);
				}
			}
#endif
		}
	}
	
	path = malloc([dbPath length] + 1);
	strcpy(path, [dbPath UTF8String]);
	
#if 0
	NSString *favoritePath = [docDir stringByAppendingPathComponent:@"FoodFavorite.db"];
	
	tmp = [favoritePath UTF8String];
	favorite_path = malloc(strlen(tmp) + 1);
	strcpy(favorite_path, tmp);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath: favoritePath] ) {
		sqlite3 *db;
		sqlite3_open([favoritePath UTF8String], &db);
		
		sqlite3_stmt *statement;
		if(sqlite3_prepare(db, "CREATE TABLE food_favorite(id integer PRIMARY KEY, food_id integer UNIQUE, food_name TEXT NOT NULL)", -1, &statement, nil) != SQLITE_OK) {
			NSLog(@"Error: failed to prepare statement:create food_favorite table");
			return NO;
		}
		int success = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if (success != SQLITE_DONE) {
			NSLog(@"Error: failed to execute:CREATE TABLE food_favorite");
			return NO;
		}
		sqlite3_close(db);
	}
#endif
	// 获取tmp目录路径的方法
	// NSString *tmpDir =  NSTemporaryDirectory();
	// 获取Caches目录路径的方法
	// NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	// NSString *cachesDir = [paths objectAtIndex:0];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.mainViewController = [[[FoodMainViewController alloc] initWithNibName:@"FoodMainViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    return [self prepare_data];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    if (path) {
        free(path);
        path = NULL;
    }
#if 0
	if (favorite_path) {
		free(favorite_path);
		favorite_path = NULL;
	}
#endif
}

@end
