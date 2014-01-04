//
//  PickerCell.m
//  Tuning Master
//
//  Created by Jason Ji on 1/3/14.
//  Copyright (c) 2014 Jason Ji. All rights reserved.
//

#import "PickerCell.h"

@implementation PickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
