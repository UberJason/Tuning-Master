//
//  JYJViewController.h
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

@import UIKit;
@import AudioToolbox;
@import AVFoundation;
@import AudioUnit;
#import "JYJConstants.h"
#import "JYJNote.h"
#import "JYJMusicModel.h"
#import "JYJAppDelegate.h"
#import "Note+Helpers.h"
#import "Sequence+Helpers.h"
#import "JYJNoteCell.h"
#import "PickerCell.h"

@interface JYJMainController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSTimer *playlistTimer;
@property (strong, nonatomic) NSTimer *stopTimer;
@property (strong, nonatomic) NSTimer *metronomeTimer;

@property (strong, nonatomic) NSMutableArray *userList;

@property (strong, nonatomic) JYJMusicModel *model;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSIndexPath *pickerCellIndexPath;

@property (strong, nonatomic) NSArray *noteImageURLs;
@property (strong, nonatomic) NSArray *noteTypeImageURLs;
@property (strong, nonatomic) NSArray *displayableNoteNames;

@end
