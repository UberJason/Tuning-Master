//
//  JYJViewController.m
//  Tuning Master
//
//  Created by Jason Ji on 12/7/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//

#import "JYJMainController.h"

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
    
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 1.0;
    
	// Get the tone parameters out of the view controller
	JYJMainController *viewController = (__bridge JYJMainController *)inRefCon;
	double theta = viewController.theta;
	double theta_increment = 2.0 * M_PI * viewController.noteFrequency / viewController.sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController.theta = theta;
    
	return noErr;
}

@interface JYJMainController ()

@end

@implementation JYJMainController

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
    NSAssert1(self.toneUnit, @"Error creating unit1: %hd", err);

	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(self.toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %hd", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = self.sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (self.toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

- (IBAction)play {

//    [self setUpPlayList];
    [self playMetronomeClick];
    [self playNoteInList:nil];

    self.playlistTimer = [NSTimer scheduledTimerWithTimeInterval:[self timeIntervalForTempo:self.tempo]
                                                          target:self
                                                        selector:@selector(playNoteInList:)
                                                        userInfo:nil
                                                         repeats:YES];
    self.metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:[self timeIntervalForTempo:self.tempo]
                                                           target:self
                                                         selector:@selector(playMetronomeClick)
                                                         userInfo:nil
                                                          repeats:YES];
}

//-(void)setUpPlayList {
//    self.sequenceToPlay = [NSMutableArray new];
//    for(JYJNote *noteObj in self.userList) {
//        if(self.sequenceToPlay.lastObject && [noteObj hasSameFrequencyAs:self.sequenceToPlay.lastObject]) {
//                ((JYJNote *)(self.sequenceToPlay.lastObject)).noteLength+= noteObj.noteLength;
//        }
//        else {
//            [self.sequenceToPlay addObject:noteObj];
//        }
//    }
//}

-(void)playTone {
    NSLog(@"play tone");
    [self createToneUnit];
    
    // Stop changing parameters on the unit
    OSErr err = AudioUnitInitialize(self.toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
    
    // Start playback
    err = AudioOutputUnitStart(self.toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
}

-(void)stopTone {
    NSLog(@"stop tone");
    if (self.toneUnit)
	{
		AudioOutputUnitStop(self.toneUnit);
		AudioUnitUninitialize(self.toneUnit);
		AudioComponentInstanceDispose(self.toneUnit);
		self.toneUnit = nil;
        
	}
    [self.stopTimer invalidate];
}

-(void)didFinishPlayingNote:(NSTimer *)timer {
    NSLog(@"didFinishPlayingNote, stopping tone");
//    if([timer.userInfo boolValue])
        [self stopTone];
//    [self playNoteInList:nil];
}
-(void)playMetronomeClick {
//    NSLog(@"play metronome");
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"CABASA" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

-(void)playToneWithFrequency:(double)frequency duration:(NSTimeInterval)duration shorterThanQuarterNote:(BOOL)shortNote stopAtEnd:(BOOL)stop {
    NSLog(@"playToneWithFrequency duration = %f", duration);
    
//    if(!self.toneUnit || self.noteFrequency != frequency) {    // if self.toneUnit exists, it's playing a note; if the note is different than the current note, stop it
    if(self.toneUnit)
        [self stopTone];

    self.noteFrequency = frequency;
    
    [self playTone];
//    }
    
    if(shortNote) {
        // TODO: invalidate playlistTimer after short note's duration and make it fire and start again
        // probably something involving perform selector after delay and [playlistTimer fire]
    }
        
    
//    if(stop)
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFinishPlayingNote:) userInfo:[NSNumber numberWithBool:stop] repeats:NO];

}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo {
    return 60.0/tempo;
}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo noteLength:(double)noteLength {
    return [self timeIntervalForTempo:self.tempo]*noteLength;
}

-(void)playNoteInList:(NSTimer *)timer {

    if(self.indexOfSequence >= self.sequenceToPlay.count) {
        [self goodNote_EverybodyBackToOne];
        return;
    }
    
    JYJNote *note = self.sequenceToPlay[self.indexOfSequence];
    NSLog(@"call playNoteInList - index = %d, note frequency = %f", self.indexOfSequence, note.frequency);
    
    double frequency = note.frequency;
    BOOL stop = NO;

//    if(self.indexOfSequence < self.sequenceToPlay.count-1)
//        stop = NO;
//    else
//        stop = YES;
    
    
//    if(self.toneUnit) {  // if the note is still playing and it's the same as the next note, let it go on.
//        NSLog(@"note is still playing so NOT playing a new tone");
//        return;
//    }
    [self playToneWithFrequency:frequency duration: [self timeIntervalForTempo:self.tempo noteLength:note.noteLength] shorterThanQuarterNote:(note.noteLength < QUARTER_NOTE) stopAtEnd:stop];
    
    self.indexOfSequence++;
    
}

-(void)goodNote_EverybodyBackToOne {
    [self stopTone];
    [self.playlistTimer invalidate];
    [self.stopTimer invalidate];
    [self.metronomeTimer invalidate];
    self.indexOfSequence = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    self.noteFrequency = 440.0;
	self.sampleRate = 44100;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:true error:nil];
    
    self.tempo = 120.0;
    
    self.sequenceToPlay = [@[
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:A octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:B octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:5] noteLength:QUARTER_NOTE]
                            ] mutableCopy];
    
//    self.sequenceToPlay = @[@(440), @(440), @(550), @(440), @(440), @(500), @(350)];
//    self.sequenceToPlay = @[
//                             [[JYJNote alloc] initWithFrequency:440 noteLength:EIGHTH_NOTE],
//                             [[JYJNote alloc] initWithFrequency:500 noteLength:QUARTER_NOTE],
//                             [[JYJNote alloc] initWithFrequency:550 noteLength:HALF_NOTE],
//                             [[JYJNote alloc] initWithFrequency:500 noteLength:QUARTER_NOTE],
//                             
//                            ];

//    self.sequenceToPlay = @[ [[JYJNote alloc] initWithNote: [NSString stringWithFormat:@"%@-%d", A_SHARP_B_FLAT, OCTAVE_4] noteLength:EIGHTH_NOTE] ];
    
//    self.sequenceToPlay = @[ [[JYJNote alloc] initWithFrequency:440 noteLength:WHOLE_NOTE] ];
    
//    NSLog(@"Distance from %@ to A-4: %d", [@[C_SHARP_D_FLAT, @(3)] componentsJoinedByString:@"-"],[JYJNote distanceToOriginFromNote:C_SHARP_D_FLAT octave:3]);
    
//    NSLog(@"frequency for A 4: %f", [JYJNote frequencyForNote: [JYJNote noteStringFromNote:A octave:4]]);
//    [JYJNote setOriginFrequency:442.0];
//    NSLog(@"frequency for A 4: %f", [JYJNote frequencyForNote: [JYJNote noteStringFromNote:A octave:4]]);
}

@end
