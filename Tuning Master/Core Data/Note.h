//
//  Note.h
//  Tuning Master
//
//  Created by Jason Ji on 12/28/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sequence;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSNumber * noteLength;
@property (nonatomic, retain) NSString * noteName;
@property (nonatomic, retain) NSNumber * octaveNumber;
@property (nonatomic, retain) NSNumber * rest;
@property (nonatomic, retain) NSString * baseNoteName;
@property (nonatomic, retain) NSNumber * halfStep;
@property (nonatomic, retain) Sequence *sequence;

@end
