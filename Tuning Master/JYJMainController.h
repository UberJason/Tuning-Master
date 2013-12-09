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

@interface JYJMainController : UIViewController

@property (nonatomic) AudioComponentInstance toneUnit;

@property (nonatomic) double noteFrequency;
@property (nonatomic) double tempo;     // in beats per minute

@property (nonatomic) double sampleRate;
@property (nonatomic) double theta;

@property (strong, nonatomic) NSTimer *playlistTimer;
@property (strong, nonatomic) NSTimer *stopTimer;
@property (strong, nonatomic) NSTimer *metronomeTimer;

@property (nonatomic) NSInteger indexOfSequence;
@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) NSMutableArray *sequenceToPlay;

@end
