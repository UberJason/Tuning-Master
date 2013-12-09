//
//  JYJNote.m
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJNote.h"

#define ORIGIN_INDEX 9
#define OCTAVE_SIZE 12
#define ORIGIN_OCTAVE 4

@implementation JYJNote

static double originFrequency = 440.0;

+(NSArray *)noteArray {
    return @[C, C_SHARP_D_FLAT, D, D_SHARP_E_FLAT, E, F, F_SHARP_G_FLAT, G, G_SHARP_A_FLAT, A, A_SHARP_B_FLAT, B];
}
+(NSString *)originNote {
    return A;
}
+(double)originFrequency {
    return originFrequency;
}
+(void)setOriginFrequency:(double)newFreq {
    originFrequency = newFreq;
}
+(NSString *)noteStringFromNote:(NSString *)noteName octave:(NSInteger)octave {
    return [@[noteName, @(octave)] componentsJoinedByString:@"-"];
}


-(JYJNote *)initWithFrequency:(double)frequency noteLength:(double)noteLength {
    self = [self init];
    if(self) {
        _frequency = frequency;
        _noteLength = noteLength;
        _noteName = nil;
        _octaveNumber = -1;
        _rest = NO;
    }
    
    return self;
}

-(JYJNote *)initWithNote:(NSString *)note noteLength:(double)noteLength {
    self = [self init];
    if(self) {
    
        _noteName = [note componentsSeparatedByString:@"-"][0];
        _octaveNumber = [[note componentsSeparatedByString:@"-"][1] doubleValue];
        _noteLength = noteLength;
        _frequency = [JYJNote frequencyForNote:note];
        _rest = NO;
    }
    
    return self;
}

-(JYJNote *)initWithRestForLength:(double)noteLength {
    self = [self init];
    if(self) {
        _noteName = REST;
        _octaveNumber = -1;
        _noteLength = noteLength;
        _frequency = -1;
        _rest = YES;
        
    }
    return self;
}

-(void)recomputeNoteFrequency {
    NSString *note = [@[self.noteName, @(self.octaveNumber)] componentsJoinedByString:@"-"];
    self.frequency = [JYJNote frequencyForNote:note];
}

-(BOOL)hasSameFrequencyAs:(JYJNote *)other {
    return (self.frequency == other.frequency || ([self.noteName isEqualToString:other.noteName] && self.octaveNumber == other.octaveNumber));
}

+(NSInteger)distanceToOriginFromNote:(NSString *)noteName octave:(NSInteger)octave {
    NSInteger noteIndex = [[JYJNote noteArray] indexOfObject:noteName];
    NSInteger index_distance = noteIndex - ORIGIN_INDEX;
    NSInteger octave_distance = octave - ORIGIN_OCTAVE;
    
    return index_distance + OCTAVE_SIZE*octave_distance;
    
}

+(double)frequencyForNote:(NSString *)note {
    
    NSArray *noteComponents = [note componentsSeparatedByString:@"-"];
    NSInteger distanceFromOrigin = [self distanceToOriginFromNote:noteComponents[0] octave:[noteComponents[1] integerValue]];
    
    double a = pow(2, 1.0/12.0);
    double frequency = [self originFrequency] * pow(a, distanceFromOrigin);

    return frequency;;
}

+(NSInteger)ignoreCountForNoteLength:(double)noteLength {

    return noteLength*4.0-1;
    
}
@end
