//
//  JYJNote.m
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJNote.h"

@implementation JYJNote

+(NSDictionary *)noteFrequencyDictionary {
    return @{ A : @(440.0),
              A_SHARP_B_FLAT : @(500),
              };
}

-(JYJNote *)initWithFrequency:(double)frequency noteType:(double)noteType {
    self = [self init];
    if(self) {
        self.frequency = frequency;
        self.noteType = noteType;
    }
    
    return self;
}

-(JYJNote *)initWithNote:(NSString *)note noteType:(double)noteType {
    self = [self init];
    if(self) {

        self.noteType = noteType;
    }
    
    return self;
}

+(double)frequencyForNote:(NSString *)note {
    
    if([JYJNote noteFrequencyDictionary][note]) {
        return [[JYJNote noteFrequencyDictionary][note] doubleValue];
    }
    
    return -1;
}
@end
