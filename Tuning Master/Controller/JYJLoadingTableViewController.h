//
//  JYJLoadingTableViewController.h
//  Tuning Master
//
//  Created by Jason Ji on 3/7/14.
//  Copyright (c) 2014 Jason Ji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sequence+Helpers.h"
#import "JYJCenterLabelCell.h"

@class JYJBaseViewController;

@interface JYJLoadingTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *fetchedResultsArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) JYJBaseViewController *delegate;

@end
