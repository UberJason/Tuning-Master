//
//  JYJNoteHelper.m
//  Tuning Master
//
//  Created by Jason Ji on 12/13/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJNoteHelper.h"

@implementation JYJNoteHelper

static double originFrequency = 440.0;

+(NSString *)originNote {
    return A;
}
+(double)originFrequency {
    return originFrequency;
}
+(void)setOriginFrequency:(double)newFreq {
    originFrequency = newFreq;
}

@end
