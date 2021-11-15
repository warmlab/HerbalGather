//
//  FoodCounteractViewController.h
//  HerbalGather
//
//  Created by 狼 恶 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodCounteractViewController : UITableViewController {
    NSInteger foodId1;
    NSInteger foodId2;
}

@property (assign, atomic) NSInteger foodId1, foodId2;
@end
