//
//  JYJBaseViewController.h
//  Tuning Master
//
//  Created by Jason Ji on 1/4/14.
//  Copyright (c) 2014 Jason Ji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYJSequenceTableViewController.h"

@interface JYJBaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeight;
@property (strong, nonatomic) JYJSequenceTableViewController *sequenceTableViewController;

//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIView *bottomNavigationView;

//-(void)modifyContainerHeight:(CGFloat)height;

@end
