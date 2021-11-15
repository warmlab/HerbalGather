//
//  FoodData.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

extern const char *path;

#import "FoodData.h"
#import "WLCrypto.h"

@implementation FoodData

#pragma mark - Favorite Table

+(NSInteger) insertFavoriteFood: (NSInteger) foodId {
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "INSERT INTO foods_favorite(id, food_id) VALUES ((SELECT MAX(id) FROM foods_favorite) + 1, ?)";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}
	rc = sqlite3_bind_int(stmt, 1, foodId);
	//rc = sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_STATIC);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

+(NSInteger) deleteFavoriteFood: (NSInteger) foodId {
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "DELETE FROM foods_favorite WHERE food_id=?";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}
	rc = sqlite3_bind_int(stmt, 1, foodId);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

+(NSInteger) queryFavoriteFood: (NSInteger) foodId {
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "SELECT id FROM foods_favorite WHERE food_id=?";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}
	rc = sqlite3_bind_int(stmt, 1, foodId);
	rc = sqlite3_step(stmt);
	if (rc == SQLITE_ROW) {
		sqlite3_finalize(stmt);
		sqlite3_close(db);
		return 1;
	}
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 0;
}

#pragma mark - Version Table

+(NSInteger) getCurrentVersion
{
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "SELECT version FROM foods_version WHERE current=1";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 1;
	}
	
	rc = sqlite3_step(stmt);
	if (rc == SQLITE_ROW) {
		NSInteger version = sqlite3_column_int(stmt, 0);
		sqlite3_finalize(stmt);
		sqlite3_close(db);
		
		return version;
	}
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

+(NSInteger) updateCurrentVersion: (NSInteger) version encrypt: (NSInteger)encrypt
{
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "REPLACE INTO foods_version(id, version, encrypt, current) VALUES (1, ?, ?, 1)";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}
	rc = sqlite3_bind_int(stmt, 1, version);
	rc = sqlite3_bind_int(stmt, 2, encrypt);
	//rc = sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_STATIC);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

#pragma mark - Food Table

+(NSInteger) updateFood: (NSDictionary *) food
{
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	NSMutableArray *keys = [NSMutableArray new];
	NSMutableArray *binds = [NSMutableArray new];
	NSMutableArray *values = [NSMutableArray new];
	for (NSString *key in food.allKeys) {
		[keys addObject: key];
		[binds addObject: @"?"];
		[values addObject: [food objectForKey: key]];
	}
	char *sql_format = "REPLACE INTO foods_food(%s) VALUES (%s)";
	char sql[512];
	sprintf(sql,  sql_format, [[keys componentsJoinedByString: @", "] UTF8String], [[binds componentsJoinedByString: @", "] UTF8String]);
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}
	
	for (NSInteger i = 0; i < values.count;  i++) {
		NSString *k = [keys objectAtIndex: i];
		if ( ![k caseInsensitiveCompare: @"id"] || ![k caseInsensitiveCompare: @"disposition"] || ![k caseInsensitiveCompare: @"flavour"] || ![k caseInsensitiveCompare: @"meridian"] || ![k caseInsensitiveCompare: @"version"])
			rc = sqlite3_bind_int(stmt, i + 1, [[values objectAtIndex: i] integerValue]);
		else if (![k caseInsensitiveCompare: @"name"] || ![k caseInsensitiveCompare: @"efficacy"] || ![k caseInsensitiveCompare: @"shiliao"]) {
			NSString *val = [WLCrypto base64_decrypt_by_aes: [values objectAtIndex: i] with: 0];
			rc = sqlite3_bind_text(stmt, i + 1, [val UTF8String], -1, SQLITE_STATIC);
		} else {
			id tmp = [values objectAtIndex: i];
			if (tmp != [NSNull null])
				rc = sqlite3_bind_text(stmt, i + 1, [tmp UTF8String], -1, SQLITE_STATIC);
		}
	}
	//rc = sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_STATIC);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

#pragma mark - Alias Table
+(NSInteger) updateAlias: (NSDictionary *) alias
{
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "REPLACE INTO foods_alias(id, food_id, name) VALUES (?, ?, ?)";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}

	rc = sqlite3_bind_int(stmt, 1, [[alias objectForKey: @"id"] integerValue]);
	rc = sqlite3_bind_int(stmt, 2, [[alias objectForKey: @"food_id"] integerValue]);
	NSString *val = [WLCrypto base64_decrypt_by_aes:[alias objectForKey:@"name"]  with:0];
	rc = sqlite3_bind_text(stmt, 3, [val UTF8String], -1, SQLITE_STATIC);
	
	//rc = sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_STATIC);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

#pragma mark - Relation Table
+(NSInteger) updateRelation: (NSDictionary *) relation
{
	sqlite3 *db;
	int rc = sqlite3_open(path, &db);
	char *sql = "REPLACE INTO foods_food(id, food1_id, food2_id, relation, nature, version) VALUES (?, ?, ?, ?, ?, ?)";

	sqlite3_stmt *stmt;
	if (sqlite3_prepare(db, sql, -1, &stmt, NULL)) {
		//NSLog(@"sqlite3_prepare(%d): %s", rc, sqlite3_errmsg(db));
		sqlite3_close(db);
		return 0;
	}

	rc = sqlite3_bind_int(stmt, 1, [[relation objectForKey: @"id"] integerValue]);
	rc = sqlite3_bind_int(stmt, 2, [[relation objectForKey: @"food1_id"] integerValue]);
	rc = sqlite3_bind_int(stmt, 3, [[relation objectForKey: @"food2_id"] integerValue]);
	rc = sqlite3_bind_int(stmt, 4, [[relation objectForKey: @"relation"] integerValue]);
	rc = sqlite3_bind_text(stmt, 5, [[relation objectForKey:@"nature"] UTF8String], -1, SQLITE_STATIC);
	rc  = sqlite3_bind_int(stmt, 4, [[relation objectForKey: @"version"] integerValue]);
	
	//rc = sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_STATIC);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	return 1;
}

@end
