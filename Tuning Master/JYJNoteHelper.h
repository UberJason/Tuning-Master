//
//  JYJNoteHelper.h
//  Tuning Master
//
//  Created by Jason Ji on 12/13/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYJConstants.h"

@interface JYJNoteHelper : NSObject

+(NSString *)originNote;
+(double)originFrequency;
+(void)setOriginFrequency:(double)newFreq;

@end
