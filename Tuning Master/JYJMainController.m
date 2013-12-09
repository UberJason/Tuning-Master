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

    [self playNoteInList:nil];
    [self playMetronomeClick];
    
    self.playlistTimer = [NSTimer scheduledTimerWithTimeInterval:[self timeIntervalForTempo:self.tempo]/4.0
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
        [self stopTone];
}
-(void)playMetronomeClick {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"CABASA" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

-(void)playToneWithFrequency:(double)frequency duration:(NSTimeInterval)duration shorterThanQuarterNote:(BOOL)shortNote {
    NSLog(@"playToneWithFrequency duration = %f", duration);
    
    if(self.toneUnit)
        [self stopTone];

    self.noteFrequency = frequency;
    
    [self playTone];
    
    if(shortNote) {
        // TODO: invalidate playlistTimer after short note's duration and make it fire and start again
        // probably something involving perform selector after delay and [playlistTimer fire]
    }
        
    
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFinishPlayingNote:) userInfo:nil repeats:NO];

}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo {
    return 60.0/tempo;
}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo noteLength:(double)noteLength {
    return [self timeIntervalForTempo:self.tempo]*noteLength;
}

-(void)playNoteInList:(NSTimer *)timer {

    if(self.ignoreCount > 0) {
        NSLog(@"ignoring!");
        self.ignoreCount--;
        return;
    }
    

    
    if(self.indexOfSequence >= self.sequenceToPlay.count) {
        [self goodNote_EverybodyBackToOne];
        return;
    }
    
    JYJNote *note = self.sequenceToPlay[self.indexOfSequence];
    self.ignoreCount = [JYJNote ignoreCountForNoteLength:note.noteLength];
    double frequency = note.frequency;
    NSLog(@"call playNoteInList - index = %d, note frequency = %f", self.indexOfSequence, note.frequency);

    [self playToneWithFrequency:frequency duration: [self timeIntervalForTempo:self.tempo noteLength:note.noteLength] shorterThanQuarterNote:(note.noteLength < QUARTER_NOTE)];
    
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
    
	self.sampleRate = 44100;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:true error:nil];
    
    self.tempo = 120.0;
    
    self.sequenceToPlay = [@[
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:WHOLE_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:5] noteLength:WHOLE_NOTE]
                            ] mutableCopy];
    
}

@end
