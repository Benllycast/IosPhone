//
//  EQUViewController.m
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import "EQUViewController.h"

@interface EQUViewController ()

@end

@implementation EQUViewController

@synthesize sliderLow, sliderMid, sliderHigh;
@synthesize trackManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    float low = [trackManager equ][0];
    float mid = [trackManager equ][1];
    float high = [trackManager equ][2];

    [sliderLow setValue:low];
    [sliderMid setValue:mid];
    [sliderHigh setValue:high];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)okAction:(id)sender {
    [trackManager setEquParameter:sliderLow.value mid:sliderMid.value high:sliderHigh.value
     ];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
