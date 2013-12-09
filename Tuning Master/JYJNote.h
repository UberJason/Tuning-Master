//
//  JYJNote.h
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

@import Foundation;
#import "JYJConstants.h"

@interface JYJNote : NSObject

@property (nonatomic) double frequency;
@property (nonatomic) double noteLength;
@property (strong, nonatomic) NSString *noteName;
@property (nonatomic) NSInteger octaveNumber;

-(JYJNote *)initWithFrequency:(double)frequency noteLength:(double)noteLength;
-(JYJNote *)initWithNote:(NSString *)note noteLength:(double)noteLength;
-(void)recomputeNoteFrequency;
-(BOOL)hasSameFrequencyAs:(JYJNote *)other;

+(NSInteger)distanceToOriginFromNote:(NSString *)noteName octave:(NSInteger)octave;
+(double)frequencyForNote:(NSString *)note;
+(NSString *)originNote;
+(double)originFrequency;
+(void)setOriginFrequency:(double)newFreq;
+(NSString *)noteStringFromNote:(NSString *)noteName octave:(NSInteger)octave;

@end
