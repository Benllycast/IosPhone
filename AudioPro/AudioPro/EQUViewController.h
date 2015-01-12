//
//  EQUViewController.h
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackManager.h"

@protocol EQUViewControllerDelegate <NSObject>

@required

-(void) setEquParameter:(id)sender low:(float) low mid:(float) mid high:(float) high;

@end

@interface EQUViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISlider *sliderLow;
@property (strong, nonatomic) IBOutlet UISlider *sliderMid;
@property (strong, nonatomic) IBOutlet UISlider *sliderHigh;

@property (nonatomic, strong) TrackManager *trackManager;

@end
