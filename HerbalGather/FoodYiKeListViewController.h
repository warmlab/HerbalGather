//
//  FoodYiKeListViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodYiKeListViewController : UITableViewController {
    NSInteger       foodId;
    NSMutableArray  *yikeList;
}

@property (assign, atomic) NSInteger foodId;

@end
