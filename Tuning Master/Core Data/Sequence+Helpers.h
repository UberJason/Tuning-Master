//
//  Sequence+Helpers.h
//  Tuning Master
//
//  Created by Jason Ji on 12/15/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "Sequence.h"
#import "JYJAppDelegate.h"

@interface Sequence (Helpers)

+(Sequence *)sequenceWithName:(NSString *)name notes:(NSOrderedSet *)notes;

@end
