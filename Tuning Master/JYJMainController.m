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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:true error:nil];
    
    double sampleRate = 44100.0;
    double tempo = 120.0;
    NSMutableArray *birthdaySequence = [@[
                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:.75],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:SIXTEENTH_NOTE],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:D octave:4] noteLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:F octave:4] noteLength:QUARTER_NOTE],
                                [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:E octave:4] noteLength:QUARTER_NOTE]
                            ] mutableCopy];
    
    NSMutableArray *straightNotesSequence = [@[
                                               [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithRestForLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:A octave:4] noteLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:B octave:4] noteLength:QUARTER_NOTE],
                                               [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:5] noteLength:QUARTER_NOTE]
                                               
                                               ] mutableCopy];
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:sampleRate tempo:tempo sequenceToPlay:straightNotesSequence];

    
//    Note* note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
//    note.frequency = @(440.0);
//    note.noteLength = @(QUARTER_NOTE);
//    note.noteName = @"A-4";
//    note.octaveNumber = @(4);
//    note.rest = @(NO);
//    
//    Note* note2 = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
//    note2.frequency = @(440.0);
//    note2.noteLength = @(QUARTER_NOTE);
//    note2.noteName = @"A-4";
//    note2.octaveNumber = @(4);
//    note2.rest = @(NO);
//    
//    Note* note3 = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
//    note3.frequency = @(440.0);
//    note3.noteLength = @(QUARTER_NOTE);
//    note3.noteName = @"A-4";
//    note3.octaveNumber = @(4);
//    note3.rest = @(NO);
//    
//    Sequence *sequence = [NSEntityDescription insertNewObjectForEntityForName:@"Sequence" inManagedObjectContext:self.managedObjectContext];
//    sequence.sequenceName = @"Test1";
//    NSOrderedSet *myNotes = [NSOrderedSet orderedSetWithArray:@[note, note2, note3]];
//    sequence.notes = myNotes;
//    
//    JYJAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    [delegate saveContext];
//
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Sequence"];
//    NSError *error;
//    NSArray *sequences = [self.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"sequences count: %d", sequences.count);
//    
//    Sequence *sequence = sequences[0];
//    NSOrderedSet *set = sequence.notes;
//    NSLog(@"sequence name: %@", sequence.sequenceName);
//    for(Note *note in set) {
//        NSLog(@"note: %@ duration: %f", note.noteName, [note.noteLength doubleValue]);
//        
//    }
}

@end
