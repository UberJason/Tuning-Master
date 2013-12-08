//
//  JYJNote.h
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

@import Foundation;
#import "JYJConstants.h"

@interface JYJNote : NSObject

@property (nonatomic) double frequency;
@property (nonatomic) double noteType;

-(JYJNote *)initWithFrequency:(double)frequency noteType:(double)noteType;

@end
