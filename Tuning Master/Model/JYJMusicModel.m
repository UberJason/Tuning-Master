//
//  JYJMusicModel.m
//  Tuning Master
//
//  Created by Jason Ji on 12/8/13.
//  Copyright (c) 2013 Jason Ji. All rights reserved.
//


#import "JYJMusicModel.h"

#pragma mark - RenderTone method (C API)

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
	JYJMusicModel *model = (__bridge JYJMusicModel *)inRefCon;
	double theta = model.theta;
	double theta_increment = 2.0 * M_PI * model.noteFrequency / model.sampleRate;
    
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
	model.theta = theta;
    
	return noErr;
}

@implementation JYJMusicModel

#pragma mark - designated initializer

-(JYJMusicModel *)initWithSampleRate:(double)sampleRate tempo:(double)tempo sequenceToPlay:(NSArray *)sequenceToPlay {
    
    self = [self init];
    
    if(self) {
        _sampleRate = sampleRate;
        _tempo = tempo;
        _sequenceToPlay = sequenceToPlay;
        [self createToneUnit];
    }
    
    return self;
}

#pragma mark - music handling methods

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

-(void)playMetronomeClick {
    NSLog(@"play metronome click");
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"CABASA" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

-(void)playToneWithFrequency:(double)frequency duration:(NSTimeInterval)duration {
    NSLog(@"playToneWithFrequency duration = %f", duration);
    
    if(self.toneUnit)
        [self stopTone];
    
    self.noteFrequency = frequency;
    
    [self playTone];
    
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(stopTone) userInfo:nil repeats:NO];
    
}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo {
    return 60.0/tempo;
}

-(NSTimeInterval)timeIntervalForTempo:(double)tempo noteLength:(double)noteLength {
    return [self timeIntervalForTempo:self.tempo]*noteLength;
}

#pragma mark - play/stop control methods

- (void)play {
    [self goodNote_EverybodyBackToOne];
    NSLog(@"****reset and CLICKED PLAY****");
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

-(void)playNoteInList:(NSTimer *)timer {
    
    if(self.ignoreCount > 0) {
        NSLog(@"ignoring!");
        self.ignoreCount--;
        return;
    }
    
    if(self.indexOfSequence >= [self.sequenceToPlay count]) {
        [self goodNote_EverybodyBackToOne];
        return;
    }
    
    Note *note = self.sequenceToPlay[self.indexOfSequence];
    self.ignoreCount = [Note ignoreCountForNoteLength:[note.noteLength doubleValue]];
    double frequency = [note.frequency doubleValue];
    NSLog(@"call playNoteInList - index = %d, note frequency = %f %@", self.indexOfSequence, [note.frequency doubleValue], (note.rest ? @"REST" : @""));
    
    if(!note.rest)
        [self playToneWithFrequency:frequency duration: [self timeIntervalForTempo:self.tempo noteLength:[note.noteLength doubleValue]]];
    
    self.indexOfSequence++;
    
}

-(void)playTone {
    NSLog(@"play tone");
//    [self createToneUnit];
    
    // Stop changing parameters on the unit
    OSErr err = AudioUnitInitialize(self.toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
    
    // Start playback
    err = AudioOutputUnitStart(self.toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
}

-(void)stopTone {
//    NSLog(@"stop tone");
    if (self.toneUnit)
	{
		AudioOutputUnitStop(self.toneUnit);
//		AudioUnitUninitialize(self.toneUnit);
//		AudioComponentInstanceDispose(self.toneUnit);
//		self.toneUnit = nil;
        
	}
    [self.stopTimer invalidate];
}

-(void)goodNote_EverybodyBackToOne {
    [self stopTone];
    [self.playlistTimer invalidate];
    [self.stopTimer invalidate];
    [self.metronomeTimer invalidate];
    self.playlistTimer = nil;
    self.stopTimer = nil;
    self.metronomeTimer = nil;
    self.indexOfSequence = 0.0;
    self.ignoreCount = 0;
}


@end
