//
//  JYJViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJSequenceTableViewController.h"
#import "JYJBaseViewController.h"

#define DEFAULT_SAMPLE_RATE 44100.0
#define DEFAULT_TEMPO 120.0

#define PICKER_CELL_HEIGHT 163
#define NORMAL_CELL_HEIGHT 44

#define NOTE_IMAGE_HEIGHT 35
#define NOTE_IMAGE_WIDTH 25
#define NOTE_TYPE_IMAGE_HEIGHT 30
#define NOTE_TYPE_IMAGE_WIDTH 10
#define NOTE_TEXT_FONT_SIZE 25

#define SIXTEENTH_URL @"sixteenth_note.png"
#define EIGHTH_URL @"eighth_note.png"
#define QUARTER_URL @"quarter_note.png"
#define HALF_URL @"half_note.png"
#define WHOLE_URL @"whole_note.png"
#define QUARTER_REST_URL @"quarter_rest.png"

#define FLAT_URL @"flat.png"
#define NATURAL_URL @"natural.png"
#define SHARP_URL @"sharp.png"

typedef enum {
    NoteLengthSixteenthNote,
    NoteLengthEighthNote,
    NoteLengthQuarterNote,
    NoteLengthHalfNote,
    NoteLengthWholeNote,
    NoteLengthQuarterRest
} NoteLength;

typedef enum {
    NoteAccentFlat,
    NoteAccentNatural,
    NoteAccentSharp
} NoteAccent;

@interface JYJSequenceTableViewController ()

@end

@implementation JYJSequenceTableViewController

#pragma mark - getters/setters

-(NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext)
        _managedObjectContext = [(JYJAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return _managedObjectContext;
}

-(JYJMusicModel *)model {
    if(!_model)
        _model = [[JYJMusicModel alloc] initWithSampleRate:DEFAULT_SAMPLE_RATE tempo:DEFAULT_TEMPO sequence:[Sequence sequenceWithName:@"New Sequence" notes:[NSOrderedSet new]]];
    
    return _model;
}

-(NSArray *)noteImageURLs {
    return @[SIXTEENTH_URL, EIGHTH_URL, QUARTER_URL, HALF_URL, WHOLE_URL, QUARTER_REST_URL];
}
-(NSArray *)noteAccentImageURLs {
    return @[FLAT_URL, NATURAL_URL, SHARP_URL];
}
-(NSArray *)displayableNoteNames {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
}
-(NSArray *)possibleNoteLengths {
    return @[@(SIXTEENTH_NOTE), @(EIGHTH_NOTE), @(QUARTER_NOTE), @(HALF_NOTE), @(WHOLE_NOTE), @(QUARTER_NOTE)];
}

-(NSArray *)possibleAccents {
    return @[@(FLAT), @(NATURAL), @(SHARP)];
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
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.alwaysBounceVertical = NO;
    
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
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:DEFAULT_SAMPLE_RATE tempo:DEFAULT_TEMPO sequence:sequence];
    Note *newNote = [Note noteWithBaseNote:[Note noteStringFromNote:C octave:4] halfStep:0 noteLength:QUARTER_NOTE];
    newNote.sequence = sequence;
    [self.model updateSequenceToPlay];
}

#pragma mark - table view delegate/datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==1)
        return 1;
    
    if(self.pickerCellIndexPath)
        return self.model.sequenceToPlay.count + 1;
    else
        return self.model.sequenceToPlay.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0 ? self.model.sequence.sequenceName : nil);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierForRowAtIndexPath:indexPath];
    if([identifier isEqualToString:@"pickerCell"])
        return PICKER_CELL_HEIGHT;
    else
        return NORMAL_CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [self identifierForRowAtIndexPath:indexPath];
    
    if([identifier isEqualToString:@"pickerCell"]) {
        PickerCell *cell = (PickerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        cell.pickerView.delegate = self;
        cell.pickerView.dataSource = self;
        
        Note *note = self.model.sequence.notes[indexPath.row-1];
        
        if(note.isRest) {
            [cell.pickerView selectRow:5 inComponent:0 animated:NO];
        }
        else {
            [cell.pickerView selectRow:[self pickerRowForNoteLength:[note.noteLength doubleValue]] inComponent:0 animated:NO];
            [cell.pickerView selectRow:[self.displayableNoteNames indexOfObject:note.baseNoteName] inComponent:1 animated:NO];
            [cell.pickerView selectRow:[self pickerRowForAccent:[note.halfStep integerValue]] inComponent:2 animated:NO];
            [cell.pickerView selectRow:[note.octaveNumber integerValue]-3 inComponent:3 animated:NO];
        }
        
        return cell;
    }
    else if([identifier isEqualToString:@"addCell"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.textLabel.text = @"Add a note...";
        
        return cell;
    }
    else {
        NSInteger row = (self.pickerCellIndexPath && self.pickerCellIndexPath.row < indexPath.row) ? indexPath.row-1 : indexPath.row;
        
        JYJNoteCell *cell = (JYJNoteCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        Note *note = ((Note *)self.model.sequence.notes[row]);
        
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {    // add cell was tapped; add a note to the end of the sequence.
        [self addNewNote];
    }
    else if(self.pickerCellIndexPath && self.pickerCellIndexPath.row == indexPath.row) {
        // do nothing, should not select the picker cell.
    }
    else if(self.pickerCellIndexPath && self.pickerCellIndexPath.row == indexPath.row+1)  {// if the picker cell is showing right below this cell, hide it and we're done.
        self.pickerCellIndexPath = nil;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [self.delegate modifyContainerHeight:-1*PICKER_CELL_HEIGHT];
    }
    else if(self.pickerCellIndexPath && self.pickerCellIndexPath.row < indexPath.row) { // if the picker cell is showing somewhere above the current cell, hide it and show it here
        NSIndexPath *oldPickerIndexPath = self.pickerCellIndexPath;
        self.pickerCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[oldPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[self.pickerCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else if(self.pickerCellIndexPath && self.pickerCellIndexPath.row > indexPath.row) { // if the picker cell is showing somewhere below the current cell, hide it and show it here
        NSIndexPath *oldPickerIndexPath = self.pickerCellIndexPath;
        self.pickerCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[oldPickerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[self.pickerCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else {  // if there is no picker cell showing
        self.pickerCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[self.pickerCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [self.delegate modifyContainerHeight:PICKER_CELL_HEIGHT];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierForRowAtIndexPath:indexPath];
    if([identifier isEqualToString:@"pickerCell"] || [identifier isEqualToString:@"addCell"])
        return NO;
    else
        return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        if(self.pickerCellIndexPath) {  // if the picker cell is showing, we will delete it as well
            Note *noteToDelete = (self.pickerCellIndexPath.row < indexPath.row ? self.model.sequenceToPlay[indexPath.row-1] : self.model.sequenceToPlay[indexPath.row]);
            noteToDelete.sequence = nil;
            [self.model updateSequenceToPlay];
            NSIndexPath *formerPickerCellIndexPath = self.pickerCellIndexPath;
            self.pickerCellIndexPath = nil;
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[formerPickerCellIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            [self.delegate modifyContainerHeight:-1*(NORMAL_CELL_HEIGHT+PICKER_CELL_HEIGHT)];
        }

        else {  // if there is no picker cell showing
            Note *noteToDelete = self.model.sequenceToPlay[indexPath.row];
            noteToDelete.sequence = nil;
            [self.model updateSequenceToPlay];
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            [self.delegate modifyContainerHeight:-1*NORMAL_CELL_HEIGHT];
        }
    }
}

-(NSString *)identifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        return @"addCell";
    
    if(self.pickerCellIndexPath) {
        if(indexPath.row == self.pickerCellIndexPath.row)
            return @"pickerCell";
        else
            return @"noteCell";
    }
    else {
            return @"noteCell";
    }
}

#pragma mark - target/action methods

- (IBAction)play {
    [self.model play];
}
- (IBAction)stop {
    [self.model goodNote_EverybodyBackToOne];
}

#pragma mark - UIPickerView delegate/data source methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch(component) {
        case 0: return 6;   // note type: sixteenth, eighth, quarter, half, whole, quarter-rest
            break;
        case 1: return 7;   // note: A, B, C, D, E, F, G
            break;
        case 2: return 3;   // sharp, flat, or natural
            break;
        case 3: return 6;   // octave: 3, 4, 5, 6, 7, 8
            break;
    }
    
    return -1;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if(view)
        return view;
    
    switch(component) {
        case 0: return [self noteImageForPickerViewForRow:row];
            break;
        case 1: return [self noteLabelForPickerViewForRow:row];
            break;
        case 2: return [self noteAccentImageForPickerViewForRow:row];
            break;
        case 3: return [self octaveLabelForPickerViewForRow:row];
            break;
    }
    
    return nil;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return NOTE_IMAGE_HEIGHT;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [self updateNoteAtIndex:self.pickerCellIndexPath.row-1 withValuesFromPicker:pickerView];
    
}

#pragma mark - helpers

-(void)addNewNote {
    Note *lastNoteInSequence = self.model.sequenceToPlay[self.model.sequence.notes.count-1];
    Note *newNote = [Note noteFromOtherNote:lastNoteInSequence];
    newNote.sequence = self.model.sequence;
    [self.model updateSequenceToPlay];
    
    [self.tableView beginUpdates];
    if(self.pickerCellIndexPath)
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.model.sequenceToPlay.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    else
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.model.sequenceToPlay.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.delegate modifyContainerHeight:NORMAL_CELL_HEIGHT];
    
}

-(void)updateNoteAtIndex:(NSInteger)index withValuesFromPicker:(UIPickerView *)pickerView {
    
    Note *note = self.model.sequence.notes[index];
    NSLog(@"Note: %@", [note description]);
    if([pickerView selectedRowInComponent:0] == [self.noteImageURLs indexOfObject:QUARTER_REST_URL]) {  // handle special case of quarter rest
        NSLog(@"quarter rest selected");
        note.noteName = REST;
        note.octaveNumber = @(-1);
        note.noteLength = @(QUARTER_NOTE);
        note.frequency = @(-1);
        note.rest = @(YES);
    }
    else {
        
        double noteLength = [self noteLengthForNoteLengthEnum:(NoteLength)[pickerView selectedRowInComponent:0]];
        NSString *baseNoteLabel = self.displayableNoteNames[[pickerView selectedRowInComponent:1]];
        NSInteger halfStep = [self halfStepForNoteAccent:(NoteAccent)[pickerView selectedRowInComponent:2]];
        NSInteger octaveNumber = [pickerView selectedRowInComponent:3]+3;
        
        [note updateValuesForBaseNote:[Note noteStringFromNote:baseNoteLabel octave:octaveNumber] noteLength:noteLength halfStep:halfStep octaveNumber:octaveNumber];
        
    }
    
    [self.tableView reloadData];
    
}

-(UIImageView *)noteImageForPickerViewForRow:(NSInteger)row {   // sixteenth, eighth, quarter, half, whole, quarter-rest
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.noteImageURLs[row]]];
    imageView.frame = CGRectMake(0, 0, NOTE_IMAGE_WIDTH, NOTE_IMAGE_HEIGHT);
    return imageView;
}

-(UILabel *)noteLabelForPickerViewForRow:(NSInteger)row {   // A, B, C, D, E, F, G
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, NOTE_IMAGE_WIDTH, NOTE_IMAGE_HEIGHT)];
    label.text = self.displayableNoteNames[row];
    label.font = [UIFont systemFontOfSize:NOTE_TEXT_FONT_SIZE];
    return label;
}
-(UIImageView *)noteAccentImageForPickerViewForRow:(NSInteger)row {   // sharp, flat, natural
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.noteAccentImageURLs[row]]];
    imageView.frame = CGRectMake(0, 0, NOTE_TYPE_IMAGE_WIDTH, NOTE_TYPE_IMAGE_HEIGHT);
    return imageView;
}
-(UILabel *)octaveLabelForPickerViewForRow:(NSInteger)row { // 3, 4, 5, 6, 7, 8
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, NOTE_IMAGE_WIDTH, NOTE_IMAGE_HEIGHT)];
    label.text = [NSString stringWithFormat:@"%ld", row+3];
    label.font = [UIFont systemFontOfSize:NOTE_TEXT_FONT_SIZE];
    return label;
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

#pragma mark - methods to convert note lengths to picker rows and back
-(double)noteLengthForNoteLengthEnum:(NoteLength)note {
    
    return [self.possibleNoteLengths[note] doubleValue];
}

-(NSInteger)pickerRowForNoteLength:(double)noteLength {
    return [self.possibleNoteLengths indexOfObject:@(noteLength)];
}

#pragma mark - methods to convert accents to picker rows and back

-(NSInteger)halfStepForNoteAccent:(NoteAccent)note {
    switch(note) {
        case NoteAccentFlat: return -1;
        case NoteAccentNatural: return 0;
        case NoteAccentSharp: return 1;
    }
}

-(NSInteger)pickerRowForAccent:(NSInteger)accent {
    return [self.possibleAccents indexOfObject:@(accent)];
}

#pragma mark - methods to retrieve images

-(NSString *)imageNameForNote:(Note *)note {
    
    double length = [note.noteLength doubleValue];
    
    if(note.isRest)
        return QUARTER_REST_URL;
    
    if(length == SIXTEENTH_NOTE)
        return SIXTEENTH_URL;
    else if(length == EIGHTH_NOTE)
        return EIGHTH_URL;
    else if(length == QUARTER_NOTE)
        return QUARTER_URL;
    else if(length == HALF_NOTE)
        return HALF_URL;
    else if(length == WHOLE_NOTE)
        return WHOLE_URL;
    
    return @"ERROR";
}

-(NSString *)sharpFlatImageForNote:(Note *)note {
    if([note.halfStep integerValue] == -1)
        return FLAT_URL;
    else if([note.halfStep integerValue] == 0)
        return nil;
    else
        return SHARP_URL;
}

@end
