//
//  FxManager.m
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//


#import "SuperpoweredReverb.h"
#import "SuperpoweredFilter.h"
#import "Superpowered3BandEQ.h"
#import "SuperpoweredEcho.h"
#import "SuperpoweredRoll.h"
#import "SuperpoweredFlanger.h"
#import "FxManager.h"

@implementation FxManager{
    SuperpoweredFX *effects[NUMFXUNITS];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        SuperpoweredFilter *filter = new SuperpoweredFilter(SuperpoweredFilter_Resonant_Lowpass, 44100);
        filter->setResonantParameters(1000.0f, 0.1f);
        effects[FILTERINDEX] = filter;

        effects[ROLLINDEX] = new SuperpoweredRoll(44100);
        effects[FLANGERINDEX] = new SuperpoweredFlanger(44100);

        SuperpoweredEcho *delay = new SuperpoweredEcho(44100);
        delay->setMix(0.8f);
        effects[DELAYINDEX] = delay;

        SuperpoweredReverb *reverb = new SuperpoweredReverb(44100);
        reverb->setRoomSize(0.5f);
        reverb->setMix(0.3f);
        effects[REVERBINDEX] = reverb;

        Superpowered3BandEQ *eq = new Superpowered3BandEQ(44100);
        eq->bands[0] = 2.0f;
        eq->bands[1] = 0.5f;
        eq->bands[2] = 2.0f;
        effects[EQINDEX] = eq;
        for (int n = 2; n < NUMFXUNITS; n++) effects[n]->enable(false);
    }
    return self;
}
-(bool) toggleFX:(int)index{
    bool enabled = effects[index]->enabled;
    effects[index]->enable(!enabled);
    return !enabled;
}

-(bool) processAllFX:(bool)silence inputBuffer:(float *)input outputBuffer:(float*)output numSamples:(uint)numberOfSamples{

    if (effects[ROLLINDEX]->process(silence ? NULL : input, output, numberOfSamples)) silence = false;
    effects[FILTERINDEX]->process(input, output, numberOfSamples);
    effects[EQINDEX]->process(input, output, numberOfSamples);
    effects[FLANGERINDEX]->process(input, output, numberOfSamples);
    if (effects[DELAYINDEX]->process(silence ? NULL : input, output, numberOfSamples)) silence = false;
    if (effects[REVERBINDEX]->process(silence ? NULL : input, output, numberOfSamples)) silence = false;
    return silence;
}

-(void) setEQUFX:(int)index low:(float)low mid:(float)mid high:(float)high{
    ((Superpowered3BandEQ *) effects[EQINDEX])->bands[0] = low;
    ((Superpowered3BandEQ *) effects[EQINDEX])->bands[1] = mid;
    ((Superpowered3BandEQ *) effects[EQINDEX])->bands[2] = high;
}

- (void)dealloc {
    for (int n = 2; n < NUMFXUNITS; n++) delete effects[n];
  #if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(float *) getEquParameter{
    Superpowered3BandEQ * equ = (Superpowered3BandEQ  *)effects[EQINDEX];
    return equ->bands;
}
@end
