//
//  JYJNoteCell.h
//  Tuning Master
//
//  Created by Jason Ji on 12/28/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYJNoteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *noteDetailsPanel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *octaveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sharpFlatImage;
@property (weak, nonatomic) IBOutlet UIImageView *lengthImage;

@end
