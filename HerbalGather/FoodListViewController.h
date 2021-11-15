//
//  FoodListViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodListViewController : UITableViewController {
    NSInteger kind;
    NSInteger classId;
    NSMutableArray *foodList;
}

@property (atomic) NSInteger kind, classId;

@end
