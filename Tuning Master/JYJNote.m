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


-(JYJNote *)initWithFrequency:(double)frequency noteType:(double)noteType {
    self = [self init];
    if(self) {
        self.frequency = frequency;
        self.noteType = noteType;
        self.noteName = nil;
        self.octaveNumber = -1;
    }
    
    return self;
}

-(JYJNote *)initWithNote:(NSString *)note noteType:(double)noteType {
    self = [self init];
    if(self) {
    
        self.noteName = [note componentsSeparatedByString:@"-"][0];
        self.octaveNumber = [[note componentsSeparatedByString:@"-"][1] doubleValue];
        self.noteType = noteType;
        self.frequency = [JYJNote frequencyForNote:note];
    }
    
    return self;
}

-(void)recomputeNoteFrequency {
    NSString *note = [@[self.noteName, @(self.octaveNumber)] componentsJoinedByString:@"-"];
    self.frequency = [JYJNote frequencyForNote:note];
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
@end
