//
//  JYJViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJMainController.h"


@interface JYJMainController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JYJMainController

#pragma mark - getters/setters 

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext)
        _managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return _managedObjectContext;
}

-(JYJMusicModel *)model {
    if(!_model)
        _model = [[JYJMusicModel alloc] initWithSampleRate:self.sampleRate tempo:self.tempo sequence:[Sequence sequenceWithName:@"New Sequence" notes:[NSOrderedSet new]]];
    
    return _model;
}

-(double)sampleRate {
    if(_sampleRate == 0.0)
        _sampleRate = 44100.0;
    
    return _sampleRate;
}
-(double)tempo {
    if(_tempo == 0.0)
        _tempo = 120.0;
    return _tempo;
}

#pragma mark - view controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self deleteAllFromCoreData];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:true error:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    double sampleRate = 44100.0;
//    double tempo = 120.0;
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

    NSMutableArray *coreDataSequence = [@[
                                            [Note noteWithRestForLength:QUARTER_NOTE],
                                            [Note noteWithRestForLength:QUARTER_NOTE],
                                            [Note noteWithRestForLength:QUARTER_NOTE],
                                            [Note noteWithBaseNote:[Note noteStringFromNote:G octave:4] halfStep:1 noteLength:QUARTER_NOTE],
                                            [Note noteWithBaseNote:[Note noteStringFromNote:A octave:4] halfStep:-1 noteLength:QUARTER_NOTE],
                                            [Note noteWithBaseNote:[Note noteStringFromNote:G octave:4] halfStep:0 noteLength:QUARTER_NOTE],
                                            [Note noteWithBaseNote:[Note noteStringFromNote:G octave:4] halfStep:0 noteLength:QUARTER_NOTE],
                                          ] mutableCopy];

    NSOrderedSet *noteSet = [NSOrderedSet orderedSetWithArray:coreDataSequence];
    Sequence *testSequence = [Sequence sequenceWithName:@"testSet1" notes:noteSet];
    [self.managedObjectContext save:nil];

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
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:self.sampleRate tempo:self.tempo sequence:sequence];
    
}

#pragma mark - table view delegate/datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? self.model.sequenceToPlay.count : 1);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0 ? self.model.sequence.sequenceName : nil);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier;
    
    if(indexPath.section == 0) {
    
        identifier = @"noteCell";
        
        JYJNoteCell *cell = (JYJNoteCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        Note *note = ((Note *)self.model.sequence.notes[indexPath.row]);

        cell.lengthImage.image = [UIImage imageNamed:[self imageNameForNote:note]];
        
        if(note.isRest) {
            cell.noteDetailsPanel.hidden = YES;
        }
        else {
            cell.noteDetailsPanel.hidden = NO;
            cell.noteLabel.text = note.baseNoteName;
            cell.octaveLabel.text = [NSString stringWithFormat:@"%ld", (long)[note.octaveNumber integerValue]];
            cell.sharpFlatImage.image = [UIImage imageNamed:[self sharpFlatImageForNote:note]];
        }
        return cell;
    }
    else {
        identifier = @"playStopCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.textLabel.text = @"Play";

        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        [self.model play];
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

#pragma mark - target/action methods

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

#pragma mark - helpers

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

-(NSString *)imageNameForNote:(Note *)note {
    
    double length = [note.noteLength doubleValue];
    
    if(note.isRest)
        return @"quarter_rest.png";
    
    if(length == SIXTEENTH_NOTE)
        return @"sixteenth_note.png";
    else if(length == EIGHTH_NOTE)
        return @"eighth_note.png";
    else if(length == QUARTER_NOTE)
        return @"quarter_note.png";
    else if(length == HALF_NOTE)
        return @"half_note.png";
    else if(length == WHOLE_NOTE)
        return @"whole_note.png";
    
    return @"ERROR";
}

-(NSString *)sharpFlatImageForNote:(Note *)note {
    if([note.halfStep integerValue] == -1)
        return @"flat.png";
    else if([note.halfStep integerValue] == 0)
        return @"natural.png";
    else
        return @"sharp.png";
}

@end
