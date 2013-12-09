//
//  JYJMusicModel.h
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

@import Foundation;
@import AudioToolbox;
@import AVFoundation;
@import AudioUnit;
#import "JYJConstants.h"
#import "JYJNote.h"

@interface JYJMusicModel : NSObject

@property (nonatomic) AudioComponentInstance toneUnit;

@property (nonatomic) double noteFrequency;
@property (nonatomic) double tempo;     // in beats per minute

@property (nonatomic) double sampleRate;
@property (nonatomic) double theta;

@property (strong, nonatomic) NSTimer *playlistTimer;
@property (strong, nonatomic) NSTimer *stopTimer;
@property (strong, nonatomic) NSTimer *metronomeTimer;

@property (nonatomic) NSInteger indexOfSequence;
@property (nonatomic) NSInteger ignoreCount;
@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) NSMutableArray *sequenceToPlay;

-(JYJMusicModel *)initWithSampleRate:(double)sampleRate tempo:(double)tempo sequenceToPlay:(NSMutableArray *)sequenceToPlay;

-(void)play;

@end
