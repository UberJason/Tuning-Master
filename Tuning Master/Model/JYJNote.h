//
//  JYJNote.h
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

@import Foundation;
#import "JYJConstants.h"
#import "JYJNoteHelper.h"

@interface JYJNote : NSObject

@property (nonatomic) double frequency;
@property (nonatomic) double noteLength;
@property (strong, nonatomic) NSString *noteName;
@property (nonatomic) NSInteger octaveNumber;
@property (nonatomic, getter = isRest) BOOL rest;

-(JYJNote *)initWithFrequency:(double)frequency noteLength:(double)noteLength;
-(JYJNote *)initWithNote:(NSString *)note noteLength:(double)noteLength;
-(JYJNote *)initWithRestForLength:(double)noteLength;

-(void)recomputeNoteFrequency;
-(BOOL)hasSameFrequencyAs:(JYJNote *)other;

+(NSInteger)distanceToOriginFromNote:(NSString *)noteName octave:(NSInteger)octave;
+(double)frequencyForNote:(NSString *)note;
+(NSString *)noteStringFromNote:(NSString *)noteName octave:(NSInteger)octave;
+(NSInteger)ignoreCountForNoteLength:(double)noteLength;

@end
