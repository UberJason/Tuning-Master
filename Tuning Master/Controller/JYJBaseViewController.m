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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.sequenceTableViewController.tableView layoutIfNeeded];
//    self.tableViewContainerHeight.constant = self.sequenceTableViewController.tableView.contentSize.height;

    self.navigationController.navigationBar.barTintColor = [UIColor peterRiverFlatColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.bottomNavigationView.backgroundColor = [UIColor peterRiverFlatColor];
    
    [self setButtonPropertiesForButton:self.playPauseButton];
    [self setButtonPropertiesForButton:self.saveButton];
    [self setButtonPropertiesForButton:self.loadButton];
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
- (IBAction)togglePlayOrStop {
    [self.sequenceTableViewController.model play];
}


@end
