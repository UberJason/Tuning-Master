//
//  Note+Helpers.m
//  Tuning Master
//
//  Created by Jason Ji on 12/15/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "Note+Helpers.h"

#define ORIGIN_INDEX 9
#define OCTAVE_SIZE 12
#define ORIGIN_OCTAVE 4

@implementation Note (Helpers)

+(NSArray *)noteArray {
    return @[C, C_SHARP_D_FLAT, D, D_SHARP_E_FLAT, E, F, F_SHARP_G_FLAT, G, G_SHARP_A_FLAT, A, A_SHARP_B_FLAT, B];
}

+(NSString *)noteStringFromNote:(NSString *)noteName octave:(NSInteger)octave {
    return [@[noteName, @(octave)] componentsJoinedByString:@"-"];
}


+(Note *)noteWithFrequency:(double)frequency noteLength:(double)noteLength {

    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    note.frequency = @(frequency);
    note.noteLength = @(noteLength);
    note.octaveNumber = @(-1);
    note.rest = @(NO);
    
    return note;
}

+(Note *)noteWithNote:(NSString *)noteName noteLength:(double)noteLength {

    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    note.noteName = [noteName componentsSeparatedByString:@"-"][0];
    note.octaveNumber = @([[noteName componentsSeparatedByString:@"-"][1] doubleValue]);
    note.noteLength = @(noteLength);
    note.frequency = @([Note frequencyForNote:noteName]);
    note.rest = NO;
    
    return note;
}

+(Note *)noteWithRestForLength:(double)noteLength {

    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    note.noteName = REST;
    note.octaveNumber = @(-1);
    note.noteLength = @(noteLength);
    note.frequency = @(-1);
    note.rest = @(YES);
        

    return note;
}

-(void)recomputeNoteFrequency {
    NSString *note = [@[self.noteName, self.octaveNumber] componentsJoinedByString:@"-"];
    self.frequency = @([Note frequencyForNote:note]);
}

-(BOOL)hasSameFrequencyAs:(Note *)other {
    return (self.frequency == other.frequency || ([self.noteName isEqualToString:other.noteName] && self.octaveNumber == other.octaveNumber));
}

+(NSInteger)distanceToOriginFromNote:(NSString *)noteName octave:(NSInteger)octave {
    NSInteger noteIndex = [[Note noteArray] indexOfObject:noteName];
    NSInteger index_distance = noteIndex - ORIGIN_INDEX;
    NSInteger octave_distance = octave - ORIGIN_OCTAVE;
    
    return index_distance + OCTAVE_SIZE*octave_distance;
    
}

+(double)frequencyForNote:(NSString *)note {
    
    NSArray *noteComponents = [note componentsSeparatedByString:@"-"];
    NSInteger distanceFromOrigin = [self distanceToOriginFromNote:noteComponents[0] octave:[noteComponents[1] integerValue]];
    
    double a = pow(2, 1.0/12.0);
    double frequency = [JYJNoteHelper originFrequency] * pow(a, distanceFromOrigin);
    
    return frequency;;
}

+(NSInteger)ignoreCountForNoteLength:(double)noteLength {
    
    return noteLength*4.0-1;
    
}

@end
