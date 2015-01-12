//
//  ViewController.h
//  AudioPro
//
//  Created by curso-vivelab on 10/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>

#import <UIKit/UIKit.h>
#import "EQUViewController.h"
@interface ViewController : UIViewController<MPMediaPickerControllerDelegate, EQUViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UIButton *btnTrackA;
@property (strong, nonatomic) IBOutlet UIButton *btnTarckB;
@property (strong, nonatomic) IBOutlet UIButton *playPause;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UISwitch *chk3band;

- (IBAction)onPlayPause:(id)sender;
- (IBAction)onStop:(id)sender;
- (IBAction)loadTrackA:(id)sender;
- (IBAction)loadTrackB:(id)sender;


@end
