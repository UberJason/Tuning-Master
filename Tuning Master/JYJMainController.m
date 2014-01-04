//
//  JYJViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJMainController.h"

#define DEFAULT_SAMPLE_RATE 44100.0
#define DEFAULT_TEMPO 120.0

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
        _model = [[JYJMusicModel alloc] initWithSampleRate:DEFAULT_SAMPLE_RATE tempo:DEFAULT_TEMPO sequence:[Sequence sequenceWithName:@"New Sequence" notes:[NSOrderedSet new]]];
    
    return _model;
}

-(NSArray *)noteImageURLs {
    return @[@"sixteenth_note.png", @"eighth_note.png", @"quarter_note.png", @"half_note.png", @"whole_note.png", @"quarter_rest.png"];
}
-(NSArray *)noteTypeImageURLs {
    return @[@"flat.png", @"natural.png", @"sharp.png"];
}
-(NSArray *)displayableNoteNames {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
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
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:DEFAULT_SAMPLE_RATE tempo:DEFAULT_TEMPO sequence:sequence];
    
}

#pragma mark - table view delegate/datasource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        if(self.pickerCellIndexPath)
            return self.model.sequenceToPlay.count + 1;
        else
            return self.model.sequenceToPlay.count;
    }
    else return 1;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0 ? self.model.sequence.sequenceName : nil);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierForRowAtIndexPath:indexPath];
    if([identifier isEqualToString:@"pickerCell"])
        return 163;
    else
        return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [self identifierForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        
        if(self.pickerCellIndexPath && self.pickerCellIndexPath.row == indexPath.row) {
            PickerCell *cell = (PickerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            cell.pickerView.delegate = self;
            cell.pickerView.dataSource = self;
            [cell.pickerView selectRow:2 inComponent:0 animated:NO];
            [cell.pickerView selectRow:2 inComponent:1 animated:NO];
            [cell.pickerView selectRow:1 inComponent:2 animated:NO];
            [cell.pickerView selectRow:1 inComponent:3 animated:NO];
            
            return cell;
        }
        
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
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.textLabel.text = @"Play";
        
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        [self.model play];
    else {
        NSLog(@"selected at (section,row)=(%ld,%ld)", indexPath.section, indexPath.row);
        if(self.pickerCellIndexPath && self.pickerCellIndexPath.row == indexPath.row+1)  {// if the picker cell is showing, hide it
            self.pickerCellIndexPath = nil;
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else {
            self.pickerCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:@[self.pickerCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)identifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(self.pickerCellIndexPath)
            return indexPath.row == self.pickerCellIndexPath.row ? @"pickerCell" : @"noteCell";
        else
            return @"noteCell";
    }
    else
        return @"playStopCell";
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
        case 2: return [self noteSignImageForPickerViewForRow:row];
            break;
        case 3: return [self octaveLabelForPickerViewForRow:row];
            break;
    }
    
    return nil;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35;
}

#pragma mark - helpers

-(UIImageView *)noteImageForPickerViewForRow:(NSInteger)row {   // sixteenth, eighth, quarter, half, whole, quarter-rest
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.noteImageURLs[row]]];
    imageView.frame = CGRectMake(0, 0, 25, 35);
    return imageView;
}

-(UILabel *)noteLabelForPickerViewForRow:(NSInteger)row {   // A, B, C, D, E, F, G
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 35)];
    label.text = self.displayableNoteNames[row];
    label.font = [UIFont systemFontOfSize:25.0];
    return label;
}
-(UIImageView *)noteSignImageForPickerViewForRow:(NSInteger)row {   // sharp, flat, natural
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.noteTypeImageURLs[row]]];
    imageView.frame = CGRectMake(0, 0, 10, 30);
    return imageView;
}
-(UILabel *)octaveLabelForPickerViewForRow:(NSInteger)row {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 35)];
    label.text = [NSString stringWithFormat:@"%ld", row+3];
    label.font = [UIFont systemFontOfSize:25.0];
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
        return @"";
    else
        return @"sharp.png";
}

@end
