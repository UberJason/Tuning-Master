//
//  JYJNote.m
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJNote.h"

@implementation JYJNote

-(JYJNote *)initWithFrequency:(double)frequency noteType:(double)noteType {
    self = [self init];
    if(self) {
        self.frequency = frequency;
        self.noteType = noteType;
    }
    
    return self;
}

@end
