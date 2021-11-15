//
//  FoodData.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodData : NSObject

#pragma mark - Favorite Table
+(NSInteger) insertFavoriteFood: (NSInteger) foodId;
+(NSInteger) deleteFavoriteFood: (NSInteger) foodId;
+(NSInteger) queryFavoriteFood: (NSInteger) foodId;

#pragma mark - Version Table
+(NSInteger) getCurrentVersion;
+(NSInteger) updateCurrentVersion: (NSInteger) version encrypt: (NSInteger)encrypt;

#pragma mark - Food Table
+(NSInteger) updateFood: (NSDictionary *) food;

#pragma mark - Alias Table
+(NSInteger) updateAlias: (NSDictionary *) alias;

#pragma mark - Relation Table
+(NSInteger) updateRelation: (NSDictionary *) relation;

@end
