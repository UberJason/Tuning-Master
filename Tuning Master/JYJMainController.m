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


- (IBAction)play {

    [self.model play];

}
- (IBAction)stop {
    [self.model goodNote_EverybodyBackToOne];
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
    NSMutableArray *sequence = [@[
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:C octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithRestForLength:EIGHTH_NOTE],
//                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:D octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:E octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:F octave:4] noteLength:QUARTER_NOTE],
                            [[JYJNote alloc] initWithNote:[JYJNote noteStringFromNote:G octave:4] noteLength:QUARTER_NOTE]
                            ] mutableCopy];
    
    self.model = [[JYJMusicModel alloc] initWithSampleRate:sampleRate tempo:tempo sequenceToPlay:sequence];
    
}

@end
