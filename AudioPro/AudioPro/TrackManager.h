//
//  TrackManager.h
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackManager : NSObject


-(void) loadTrackA:(NSString *) nameFile;
-(void) loadTrackB:(NSString *) nameFile;
-(void) playPause:(id) sender;
-(void) crossFadder:(id) sender;
-(void) loadAllTrack;
-(bool) togglFX:(int) index;
-(float *) equ;
-(void) setEquParameter:(float) low mid:(float) mid high:(float) hig;
@end
