//
//  ViewController.m
//  AudioPro
//
//  Created by curso-vivelab on 10/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "AudioSuper.h"
#import "fftTest.h"
#import "TrackManager.h"
#import "EQUViewController.h"


@interface ViewController ()

@end

@implementation ViewController{
    AudioSuper * audioSuper;
    TrackManager *manager;
    bool SuperpoweredEnabled, fxEnabled[NUMFXUNITS], canCompare;
    int frame, config;
    double ticksToCPUPercent;
}
@synthesize chk3band;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //SuperpoweredFFTTest();
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    double ticksToSeconds = 1e-9 * double(timebase.numer) / double(timebase.denom);

    //audioSuper = [[AudioSuper alloc] init];
    manager = [[TrackManager alloc] init];

    //SuperpoweredEnabled = true;
    [audioSuper toggle];
    frame = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayPause:(id)sender {
    //[audioSuper togglePlayback];
    [manager playPause:sender];
}

- (IBAction)onStop:(id)sender {
    //[audioSuper togglePlayback];
}

- (IBAction)loadTrackA:(id)sender {
    NSString * nameFile = [[NSString alloc] initWithUTF8String:[[[NSBundle mainBundle] pathForResource:@"nuyorica" ofType:@"m4a"] fileSystemRepresentation]];
    NSLog(@"TRACK-A: %@",nameFile);
    [manager loadTrackA:nameFile];
    //[manager loadAllTrack];
}

- (IBAction)loadTrackB:(id)sender {
    NSString * nameFile = [[NSString alloc] initWithUTF8String:[[[NSBundle mainBundle] pathForResource:@"trackA" ofType:@"mp3"] fileSystemRepresentation]];
    NSLog(@"TRACK-B: %@",nameFile);
    [manager loadTrackB:nameFile];
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [audioSuper release];
    [manager release]
    [super dealloc];
#endif
}
- (IBAction)crossFadder:(id)sender {
    [manager crossFadder:sender];
}
- (IBAction)showMedia:(id)sender {
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];

    picker.delegate                     = self;
    picker.allowsPickingMultipleItems   = NO;
    picker.prompt                       = NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{

    [mediaPicker dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)enableFxTreeBand:(id)sender {
    UISwitch * s = (UISwitch *)sender;
    bool enable = false;
    if (s.tag == 2) enable = [manager togglFX:ROLLINDEX];
    if (s.tag == 3) enable = [manager togglFX:FILTERINDEX];
    if (s.tag == 4) enable = [manager togglFX:EQINDEX];
    if (s.tag == 5) enable = [manager togglFX:FLANGERINDEX];
    if (s.tag == 6) enable = [manager togglFX:DELAYINDEX];
    if (s.tag == 7) enable = [manager togglFX:REVERBINDEX];
    [s setOn:enable animated:YES];
}

-(void) setEquParameter:(id)sender low:(float) low mid:(float) mid high:(float) high{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((EQUViewController *)segue.destinationViewController).trackManager = manager;
}

@end
