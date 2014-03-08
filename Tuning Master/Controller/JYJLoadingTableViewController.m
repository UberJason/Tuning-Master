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
        _fetchedResultsArray = [self fetchSavedSequences];
    }
    return _fetchedResultsArray;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor peterRiverFlatColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)fetchSavedSequences {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequence"];
    
    NSArray *results = [[self.managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    NSArray *unsavedObjects = [self.managedObjectContext.insertedObjects allObjects];
    
    NSMutableArray *filteredResults = [NSMutableArray new];
    for(Sequence *sequence in results)
        if(![unsavedObjects containsObject:sequence])
            [filteredResults addObject:sequence];
    
    [filteredResults sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Sequence *)obj1).sequenceName compare:((Sequence *)obj2).sequenceName];
    }];
    
    return filteredResults;
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
    
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        Sequence *sequence = self.fetchedResultsArray[indexPath.row];
        cell.textLabel.text = sequence.sequenceName;
        if(sequence == self.currentLoadedSequence) {
            cell.textLabel.textColor = [UIColor emeraldFlatColor];
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@", cell.textLabel.text, @" (Current)"];
            cell.userInteractionEnabled = NO;
        }
        return cell;
    }
    else {
        JYJCenterLabelCell *cell = (JYJCenterLabelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = @"Cancel";
        cell.textLabel.textColor = [UIColor redColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        
        Sequence *loadedSequence = self.fetchedResultsArray[indexPath.row];
        [self.delegate userLoadedNewSequence:loadedSequence];
        
    }
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {

        // Edge case: if the current sequence loaded is a new sequence (i.e. not yet saved to core data),
        // [self.managedObjectContext save:nil] will commit the current sequence to Core Data when that is undesired.
        // I could find no way to tell Core Data to only save particular changes, so I have to remove the sequence
        // from the managed object context, save, and then add the sequence back into the managed object context.
        
        BOOL currentSequenceIsNewSequence = NO;
        if([self.managedObjectContext.insertedObjects containsObject:self.currentLoadedSequence])
            currentSequenceIsNewSequence = YES;
        
        [tableView beginUpdates];
        Sequence *deletedSequence = self.fetchedResultsArray[indexPath.row];
        NSLog(@"attempting to delete sequence: %@", deletedSequence.sequenceName);
        [self.managedObjectContext deleteObject:deletedSequence];
        
        if(currentSequenceIsNewSequence)
            [self.managedObjectContext deleteObject:self.currentLoadedSequence];
        
        [self.managedObjectContext save:nil];
        
        if(currentSequenceIsNewSequence)
            [self.managedObjectContext insertObject:self.currentLoadedSequence];
        
        self.fetchedResultsArray = [self fetchSavedSequences];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}
@end
