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

+(Note *)noteWithBaseNote:(NSString *)noteName halfStep:(NSInteger)halfStep noteLength:(double)noteLength {
   
    // if halfStep == 1, note is a sharp. e.g. noteName = C_SHARP_D_FLAT, halfStep = 1, means this is C#.
    // Then, baseNoteName = C.
    // if halfStep == 0, note is natural. baseNoteName = noteName.
    // if halfStep == -1, note is a flat. e.g. noteName = D_SHARP_E_FLAT, halfStep = -1, means this is Eb.
    // Then, baseNoteName = E.
    
    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    note.baseNoteName = [noteName componentsSeparatedByString:@"-"][0];
    note.octaveNumber = @([[noteName componentsSeparatedByString:@"-"][1] doubleValue]);
    note.noteLength = @(noteLength);
    note.rest = NO;
    
    NSInteger index = [[Note noteArray] indexOfObject:note.baseNoteName];
    index += halfStep;
    if(index == -1)
        index = [Note noteArray].count-1;
    if(index == [Note noteArray].count)
        index = 0;
    note.noteName = [Note noteArray][index];
    note.frequency = @([Note frequencyForNote:[Note noteStringFromNote:note.noteName octave:[note.octaveNumber integerValue]]]);
    note.halfStep = @(halfStep);

    
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

+(Note *)noteFromOtherNote:(Note *)otherNote {
    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    note.frequency = [otherNote.frequency copy];
    note.noteLength = [otherNote.noteLength copy];
    note.noteName = [otherNote.noteName copy];
    note.octaveNumber = [otherNote.octaveNumber copy];
    note.rest = otherNote.rest;
    note.baseNoteName = [otherNote.baseNoteName copy];
    note.halfStep = [otherNote.halfStep copy];
    
    return note;
}


-(void)updateValuesForBaseNote:(NSString *)baseNoteName noteLength:(double)noteLength halfStep:(NSInteger)halfStep octaveNumber:(NSInteger)octaveNumber {
    self.baseNoteName = [baseNoteName componentsSeparatedByString:@"-"][0];
    self.octaveNumber = @(octaveNumber);
    self.noteLength = @(noteLength);
    self.rest = NO;
    
    NSInteger index = [[Note noteArray] indexOfObject:self.baseNoteName];
    index += halfStep;
    if(index == -1)
        index = [Note noteArray].count-1;
    if(index == [Note noteArray].count)
        index = 0;
    self.noteName = [Note noteArray][index];
    self.frequency = @([Note frequencyForNote:[Note noteStringFromNote:self.noteName octave:[self.octaveNumber integerValue]]]);
    self.halfStep = @(halfStep);
}

-(void)recomputeNoteFrequency {
    NSString *note = [@[self.noteName, self.octaveNumber] componentsJoinedByString:@"-"];
    self.frequency = @([Note frequencyForNote:note]);
}

-(BOOL)hasSameFrequencyAs:(Note *)other {
    return (self.frequency == other.frequency || ([self.noteName isEqualToString:other.noteName] && self.octaveNumber == other.octaveNumber));
}

-(BOOL)isRest {
    return [self.rest boolValue];
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
