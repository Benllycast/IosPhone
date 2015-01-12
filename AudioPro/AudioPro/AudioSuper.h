//
//  AudioSuper.h
//  AudioPro
//
//  Created by curso-vivelab on 10/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioSuper : NSObject{
@public
    bool playing;
    uint64_t avgUnitsPerSecond, maxUnitsPerSecond;
}

// Updates the user interface according to the file player's state.
- (void)updatePlayerLabel:(UILabel *)label slider:(UISlider *)slider button:(UIButton *)button;

- (void)togglePlayback; // Play/pause.
- (void)seekTo:(float)percent; // Jump to a specific position.

- (void)toggle; // Start/stop Superpowered.
- (bool)toggleFx:(int)index; // Enable/disable fx.

@end
