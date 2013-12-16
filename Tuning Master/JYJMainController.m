//
//  JYJViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJMainController.h"


@interface JYJMainController ()

@end

@implementation JYJMainController

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext)
        _managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return _managedObjectContext;
}

- (IBAction)play {

    [self.model play];

}
- (IBAction)stop {
    [self.model goodNote_EverybodyBackToOne];
}
- (IBAction)changeFrequency {
    [JYJNoteHelper setOriginFrequency:550];
    for(JYJNote *note in self.model.sequenceToPlay)
        [note recomputeNoteFrequency];
}

-(void)deleteAllFromCoreData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequence"];
    NSError *error;
    NSArray *sequences = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    int count = 0;
    for(Sequence *sequence in sequences) {
        [self.managedObjectContext deleteObject:sequence];
        count++;
    }
    
    [self.managedObjectContext save:nil];
    NSLog(@"deleted %d Sequences", count);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    [self deleteAllFromCoreData];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:true error:nil];
    
    double sampleRate = 44100.0;
    double tempo = 120.0;
//    NSMutableArray *birthdaySequence = [@[
//                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:.75],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:SIXTEENTH_NOTE],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:D octave:4] noteLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:F octave:4] noteLength:QUARTER_NOTE],
//                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:E octave:4] noteLength:QUARTER_NOTE]
//                            ] mutableCopy];
 
//    NSMutableArray *coreDataSequence = [@[
//                                          [Note noteWithRestForLength:QUARTER_NOTE],
//                                          [Note noteWithRestForLength:QUARTER_NOTE],
//                                          [Note noteWithRestForLength:QUARTER_NOTE],
//                                          [Note noteWithNote:[Note noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE],
//                                          [Note noteWithNote:[Note noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE],
//                                          [Note noteWithNote:[Note noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE],
//                                          [Note noteWithNote:[Note noteStringFromNote:G octave:5] noteLength:QUARTER_NOTE],
//                                          ] mutableCopy];
    
//    NSOrderedSet *noteSet = [NSOrderedSet orderedSetWithArray:coreDataSequence];
//    Sequence *testSequence = [Sequence sequenceWithName:@"testSet1" notes:noteSet];
//    [self.managedObjectContext save:nil];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequence"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sequenceName == %@", @"testSet1"];
    request.predicate = predicate;
    
    NSArray *results = [ [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] executeFetchRequest:request error:nil];
    Sequence *sequence = results[0];
    
    // note this MUST BE the usage, or it breaks for some unfathomable reason! add all objects manually to a new array.
    NSMutableArray *array = [NSMutableArray new];
    
    for(Note *note in sequence.notes)
        [array addObject:note];

//    NSArray *array = [sequence.notes array];
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:sampleRate tempo:tempo sequenceToPlay:array];

}

@end
