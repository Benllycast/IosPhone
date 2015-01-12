//
//  FxManager.h
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FxManager : NSObject

-(bool) toggleFX:(int)index;
-(bool) processAllFX:(bool)silent inputBuffer:(float *)input outputBuffer:(float*)output numSamples:(uint)numberOfSamples;
-(void) setEQUFX:(int)index low:(float)low mid:(float)mid high:(float)high;
-(float *) getEquParameter;
@end
