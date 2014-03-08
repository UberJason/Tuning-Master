//
//  JYJBaseViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 1/4/14.
//  Copyright (c) 2014 Jason Ji. All rights reserved.
//

#import "JYJBaseViewController.h"

@interface JYJBaseViewController ()

@end

@implementation JYJBaseViewController

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        _managedObjectContext = ((JYJAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor peterRiverFlatColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.bottomNavigationView.backgroundColor = [UIColor peterRiverFlatColor];
    
    [self setButtonPropertiesForButton:self.playPauseButton];
    [self setButtonPropertiesForButton:self.saveButton];
    [self setButtonPropertiesForButton:self.loadButton];
//    [self setButtonPropertiesForButton:self.createNewSequenceButton];
}

-(void)setButtonPropertiesForButton:(UIButton *)button {
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 7.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedSequenceVC"]) {
        self.sequenceTableViewController = (JYJSequenceTableViewController *)segue.destinationViewController;
        self.sequenceTableViewController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"modalLoadVC"]) {
        UINavigationController *navCtrlr = (UINavigationController *)segue.destinationViewController;
        self.loadingTableViewController = (JYJLoadingTableViewController *)navCtrlr.topViewController;
        self.loadingTableViewController.delegate = self;
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
        return;
    
    self.sequenceTableViewController.model.sequence.sequenceName = [alertView textFieldAtIndex:0].text;
    [self.managedObjectContext save:nil];
    [self.sequenceTableViewController.tableView reloadData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your sequence was saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - target action methods

- (IBAction)save {
    // if insertedObjects contains this sequence, this is an unsaved sequence
    if([self.managedObjectContext.insertedObjects containsObject: self.sequenceTableViewController.model.sequence]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save" message:@"Enter a name to save this sequence." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else {
        [self.managedObjectContext save:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your sequence was saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)togglePlayOrStop {
    [self.sequenceTableViewController.model playOrStop];
}

- (IBAction)createNewSequence:(UIBarButtonItem *)sender {
    [self save];
    if([self.managedObjectContext.insertedObjects containsObject: self.sequenceTableViewController.model.sequence]) {
        // if insertedObjects contains this sequence, the user chose not to save it.
        // rollback the context before creating this new blank sequence.
        [self.managedObjectContext rollback];
    }
    Sequence *blankSequence = [Sequence sequenceWithName:@"New Sequence" notes:nil];
    [self.sequenceTableViewController updateSequence:blankSequence];
}

#pragma mark - view controller communication

-(void)userLoadedNewSequence:(Sequence *)newSequence {
    [self.managedObjectContext rollback];
    [self.sequenceTableViewController updateSequence:newSequence];
    
}
-(void)sequenceStartedPlaying {
    [self.playPauseButton setTitle:@"Stop" forState:UIControlStateNormal];
}

-(void)sequenceStoppedPlaying {
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];

}
@end
