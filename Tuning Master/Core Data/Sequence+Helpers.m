//
//  Sequence+Helpers.m
//  Tuning Master
//
//  Created by Jason Ji on 12/15/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "Sequence+Helpers.h"

@implementation Sequence (Helpers)

+(Sequence *)sequenceWithName:(NSString *)name notes:(NSOrderedSet *)notes {
    NSManagedObjectContext *managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Sequence *sequence = [NSEntityDescription insertNewObjectForEntityForName:@"Sequence" inManagedObjectContext:managedObjectContext];
    
    sequence.sequenceName = name;
    sequence.notes = notes;
    
    return sequence;
}
@end
