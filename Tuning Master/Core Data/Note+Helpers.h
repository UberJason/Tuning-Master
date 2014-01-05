//
//  Note+Helpers.h
//  Tuning Master
//
//  Created by Jason Ji on 12/15/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "Note.h"
#import "JYJConstants.h"
#import "JYJNoteHelper.h"
#import "JYJAppDelegate.h"

@interface Note (Helpers)

+(Note *)noteWithFrequency:(double)frequency noteLength:(double)noteLength;
+(Note *)noteWithNote:(NSString *)note noteLength:(double)noteLength;
+(Note *)noteWithBaseNote:(NSString *)note halfStep:(NSInteger)halfStep noteLength:(double)noteLength;
+(Note *)noteWithRestForLength:(double)noteLength;

-(void)recomputeNoteFrequency;
-(BOOL)hasSameFrequencyAs:(Note *)other;
-(BOOL)isRest;
-(void)updateValuesForBaseNote:(NSString *)baseNoteName noteLength:(double)noteLength halfStep:(NSInteger)halfStep octaveNumber:(NSInteger)octaveNumber;

+(NSInteger)distanceToOriginFromNote:(NSString *)noteName octave:(NSInteger)octave;
+(double)frequencyForNote:(NSString *)note;
+(NSString *)noteStringFromNote:(NSString *)noteName octave:(NSInteger)octave;
+(NSInteger)ignoreCountForNoteLength:(double)noteLength;

@end
