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
    self.tableViewContainerHeight.constant = self.sequenceTableViewController.tableView.contentSize.height;
    
    self.scrollView.alwaysBounceVertical = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedSequenceVC"]) {
        self.sequenceTableViewController = (JYJSequenceTableViewController *)segue.destinationViewController;
        self.sequenceTableViewController.delegate = self;
    }
}
- (IBAction)togglePlayOrStop {
    [self.sequenceTableViewController.model play];
}

-(void)modifyContainerHeight:(CGFloat)height {
    self.tableViewContainerHeight.constant += height;
}

//-(void)tableViewDidAddACell {
//    [self.sequenceTableViewController.tableView layoutIfNeeded];
//    self.tableViewContainerHeight.constant = self.sequenceTableViewController.tableView.contentSize.height;
//    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         [self.scrollView layoutIfNeeded];
//                     }
//                     completion:nil];
//}
//-(void)tableViewDidDeleteACell {
//
//}

@end
