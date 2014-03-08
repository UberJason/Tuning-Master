//
//  JYJLoadingTableViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 3/7/14.
//  Copyright (c) 2014 Jason Ji. All rights reserved.
//

#import "JYJLoadingTableViewController.h"
#import "JYJBaseViewController.h"

@interface JYJLoadingTableViewController ()

@end

@implementation JYJLoadingTableViewController


-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext)
        _managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return _managedObjectContext;
}

-(NSArray *)fetchedResultsArray {
    if(!_fetchedResultsArray) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequence"];
        
        _fetchedResultsArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    }
    return _fetchedResultsArray;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0 ? @"Select a saved sequence." : nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0 ? self.fetchedResultsArray.count : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = (indexPath.section == 0 ? @"sequenceCell" : @"cancelCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        Sequence *sequence = self.fetchedResultsArray[indexPath.row];
        cell.textLabel.text = sequence.sequenceName;
    }
    else {
        ((JYJCenterLabelCell *)cell).textLabel.text = @"Cancel";
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

@end
